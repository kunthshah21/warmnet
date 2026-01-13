import SwiftUI
import MapKit

/// A UIViewRepresentable that wraps MKMapView with native clustering support
struct ClusteredMapView: UIViewRepresentable {
    
    // MARK: - Properties
    
    let annotations: [ContactAnnotation]
    @Binding var region: MKCoordinateRegion?
    var onAnnotationSelected: ((ContactAnnotation) -> Void)?
    var onClusterTapped: ((MKClusterAnnotation) -> Void)?
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // Configure map appearance
        mapView.mapType = .standard
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsUserLocation = true
        
        // Register annotation views
        mapView.register(
            ContactAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        mapView.register(
            ClusterAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        )
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update annotations
        updateAnnotations(on: mapView)
        
        // Update region if changed
        if let region = region {
            let currentRegion = mapView.region
            if !regionsAreEqual(currentRegion, region) {
                mapView.setRegion(region, animated: true)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Private Methods
    
    private func updateAnnotations(on mapView: MKMapView) {
        // Get current contact annotations (excluding user location)
        let currentAnnotations = mapView.annotations.compactMap { $0 as? ContactAnnotation }
        let currentIds = Set(currentAnnotations.map { $0.id })
        let newIds = Set(annotations.map { $0.id })
        
        // Remove annotations that are no longer present
        let toRemove = currentAnnotations.filter { !newIds.contains($0.id) }
        if !toRemove.isEmpty {
            mapView.removeAnnotations(toRemove)
        }
        
        // Add new annotations
        let toAdd = annotations.filter { !currentIds.contains($0.id) }
        if !toAdd.isEmpty {
            mapView.addAnnotations(toAdd)
        }
    }
    
    private func regionsAreEqual(_ r1: MKCoordinateRegion, _ r2: MKCoordinateRegion) -> Bool {
        let threshold = 0.0001
        return abs(r1.center.latitude - r2.center.latitude) < threshold &&
               abs(r1.center.longitude - r2.center.longitude) < threshold &&
               abs(r1.span.latitudeDelta - r2.span.latitudeDelta) < threshold &&
               abs(r1.span.longitudeDelta - r2.span.longitudeDelta) < threshold
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: ClusteredMapView
        
        init(_ parent: ClusteredMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Handle user location
            if annotation is MKUserLocation {
                return nil
            }
            
            // Handle cluster annotations
            if let cluster = annotation as? MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
                    for: annotation
                ) as? ClusterAnnotationView
                view?.count = cluster.memberAnnotations.count
                return view
            }
            
            // Handle contact annotations
            if let contactAnnotation = annotation as? ContactAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier,
                    for: annotation
                ) as? ContactAnnotationView
                view?.configure(with: contactAnnotation)
                return view
            }
            
            return nil
        }
        
        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            // Deselect immediately to allow re-selection
            mapView.deselectAnnotation(annotation, animated: false)
            
            if let cluster = annotation as? MKClusterAnnotation {
                // Zoom into the cluster
                parent.onClusterTapped?(cluster)
            } else if let contactAnnotation = annotation as? ContactAnnotation {
                // Navigate to contact
                parent.onAnnotationSelected?(contactAnnotation)
            }
        }
    }
}

// MARK: - Contact Annotation View

final class ContactAnnotationView: MKAnnotationView {
    
    static let reuseIdentifier = "ContactAnnotationView"
    
    private let bubbleSize: CGFloat = 36
    private var bubbleView: UIView?
    private var initialLabel: UILabel?
    private var pinView: UIImageView?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        // Enable clustering
        clusteringIdentifier = ContactAnnotation.clusterIdentifier
        
        // Configure frame
        frame = CGRect(x: 0, y: 0, width: bubbleSize, height: bubbleSize + 10)
        centerOffset = CGPoint(x: 0, y: -(bubbleSize / 2 + 5))
        
        // Create bubble
        let bubble = UIView(frame: CGRect(x: 0, y: 0, width: bubbleSize, height: bubbleSize))
        bubble.layer.cornerRadius = bubbleSize / 2
        bubble.clipsToBounds = true
        
        // Add gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bubble.bounds
        gradientLayer.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemBlue.withAlphaComponent(0.8).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        bubble.layer.insertSublayer(gradientLayer, at: 0)
        
        // Add shadow
        bubble.layer.shadowColor = UIColor.systemBlue.cgColor
        bubble.layer.shadowOpacity = 0.3
        bubble.layer.shadowOffset = CGSize(width: 0, height: 2)
        bubble.layer.shadowRadius = 4
        bubble.layer.masksToBounds = false
        
        addSubview(bubble)
        bubbleView = bubble
        
        // Create initial label
        let label = UILabel(frame: bubble.bounds)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        bubble.addSubview(label)
        initialLabel = label
        
        // Create pin triangle
        let pinConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        let pinImage = UIImage(systemName: "triangle.fill", withConfiguration: pinConfig)?
            .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        let pin = UIImageView(image: pinImage)
        pin.frame = CGRect(x: (bubbleSize - 10) / 2, y: bubbleSize - 3, width: 10, height: 10)
        pin.transform = CGAffineTransform(rotationAngle: .pi)
        addSubview(pin)
        pinView = pin
    }
    
    func configure(with annotation: ContactAnnotation) {
        let initial = String(annotation.contactName.prefix(1)).uppercased()
        initialLabel?.text = initial
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        initialLabel?.text = nil
    }
}

// MARK: - Cluster Annotation View

final class ClusterAnnotationView: MKAnnotationView {
    
    static let reuseIdentifier = "ClusterAnnotationView"
    
    private let bubbleSize: CGFloat = 44
    private var bubbleView: UIView?
    private var countLabel: UILabel?
    private var pinView: UIImageView?
    
    var count: Int = 0 {
        didSet {
            countLabel?.text = "\(count)"
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        // Configure frame
        frame = CGRect(x: 0, y: 0, width: bubbleSize, height: bubbleSize + 10)
        centerOffset = CGPoint(x: 0, y: -(bubbleSize / 2 + 5))
        
        // Create bubble with purple/violet gradient for clusters
        let bubble = UIView(frame: CGRect(x: 0, y: 0, width: bubbleSize, height: bubbleSize))
        bubble.layer.cornerRadius = bubbleSize / 2
        bubble.clipsToBounds = true
        
        // Add gradient (purple to distinguish from individual pins)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bubble.bounds
        gradientLayer.colors = [
            UIColor.systemPurple.cgColor,
            UIColor.systemPurple.withAlphaComponent(0.8).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        bubble.layer.insertSublayer(gradientLayer, at: 0)
        
        // Add shadow
        bubble.layer.shadowColor = UIColor.systemPurple.cgColor
        bubble.layer.shadowOpacity = 0.3
        bubble.layer.shadowOffset = CGSize(width: 0, height: 2)
        bubble.layer.shadowRadius = 4
        bubble.layer.masksToBounds = false
        
        addSubview(bubble)
        bubbleView = bubble
        
        // Create count label
        let label = UILabel(frame: bubble.bounds)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        bubble.addSubview(label)
        countLabel = label
        
        // Create pin triangle
        let pinConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        let pinImage = UIImage(systemName: "triangle.fill", withConfiguration: pinConfig)?
            .withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
        let pin = UIImageView(image: pinImage)
        pin.frame = CGRect(x: (bubbleSize - 10) / 2, y: bubbleSize - 3, width: 10, height: 10)
        pin.transform = CGAffineTransform(rotationAngle: .pi)
        addSubview(pin)
        pinView = pin
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        countLabel?.text = nil
    }
}
