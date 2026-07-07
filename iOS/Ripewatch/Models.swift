import Foundation

struct Plant: Identifiable, Codable, Equatable {
    var id: UUID
    var createdAt: Date
    var plantName: String
    var variety: String
    var ripenWindow: String
    var notes: String

    init(id: UUID = UUID(), createdAt: Date = Date(), plantName: String = "", variety: String = "", ripenWindow: String = "", notes: String = "") {
        self.id = id
        self.createdAt = createdAt
        self.plantName = plantName
        self.variety = variety
        self.ripenWindow = ripenWindow
        self.notes = notes
    }
}
