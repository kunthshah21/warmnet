import SwiftUI
import SwiftData

struct PriorityEnrichmentScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Contact.name) private var contacts: [Contact]
    @State private var navigateToLocation = false
    
    var onSave: () -> Void
    var onFlowComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(contacts) { contact in
                            PriorityEnrichmentRow(contact: contact)
                        }
                    }
                    .padding()
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Priority Enrich")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    navigateToLocation = true
                    onSave()
                }
                .font(Font.custom("Overpass-Medium", size: 16))
                .foregroundColor(Color(red: 0.32, green: 0.57, blue: 0.87))
            }
        }
        .background(Color.white)
        .navigationDestination(isPresented: $navigateToLocation) {
            LocationEnrichmentInfoScreen(onEnrich: {
                // TODO: Navigate to actual location enrichment screen
                print("Start location enrichment")
            }, onFlowComplete: {
                print("PriorityEnrichmentScreen: onFlowComplete called")
                onFlowComplete()
            })
        }
    }
}

struct PriorityEnrichmentRow: View {
    @Bindable var contact: Contact
    
    var body: some View {
        HStack {
            Text(contact.name)
                .font(Font.custom("WorkSans-Medium", size: 16))
                .foregroundColor(.black)
                .lineLimit(1)
            
            Spacer()
            
            HStack(spacing: 8) {
                priorityButton(for: .broaderNetwork, color: .yellow)
                priorityButton(for: .keyRelationships, color: .blue)
                priorityButton(for: .innerCircle, color: .green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.black.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func priorityButton(for priority: Priority, color: Color) -> some View {
        Button {
            withAnimation(.snappy) {
                contact.priority = priority
                ReminderScheduler.scheduleNewContact(contact)
            }
        } label: {
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(contact.priority == priority ? 1.0 : 0.3))
                .frame(width: 44, height: 44)
                .overlay {
                    if contact.priority == priority {
                        Image(systemName: "checkmark")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .shadow(radius: 1)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    let contact1 = Contact(name: "Alice Smith", priority: .broaderNetwork)
    let contact2 = Contact(name: "Bob Jones", priority: .keyRelationships)
    
    container.mainContext.insert(contact1)
    container.mainContext.insert(contact2)
    
    return NavigationStack {
        PriorityEnrichmentScreen(onSave: {}, onFlowComplete: {})
            .modelContainer(container)
    }
}
