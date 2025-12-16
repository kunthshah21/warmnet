import Foundation
import SwiftData

@Model
final class Contact {
    var id: UUID
    var name: String
    var phoneCountryCode: String
    var phoneNumber: String
    var reference: String
    
    // Advanced details
    var email: String
    var city: String
    var state: String
    var country: String
    var birthday: Date?
    var company: String
    var jobTitle: String
    var notes: String
    
    var createdAt: Date
    var updatedAt: Date
    
    init(
        name: String = "",
        phoneCountryCode: String = "+1",
        phoneNumber: String = "",
        reference: String = "",
        email: String = "",
        city: String = "",
        state: String = "",
        country: String = "",
        birthday: Date? = nil,
        company: String = "",
        jobTitle: String = "",
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.phoneCountryCode = phoneCountryCode
        self.phoneNumber = phoneNumber
        self.reference = reference
        self.email = email
        self.city = city
        self.state = state
        self.country = country
        self.birthday = birthday
        self.company = company
        self.jobTitle = jobTitle
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var fullPhoneNumber: String {
        "\(phoneCountryCode) \(phoneNumber)"
    }
    
    var fullLocation: String {
        [city, state, country]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}

