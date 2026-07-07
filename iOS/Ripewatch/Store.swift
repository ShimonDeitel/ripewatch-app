import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Plant] = []
    @Published var isPro: Bool = false

    static let freeLimit = 15

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("ripewatch_items.json")
        load()
    }

    var canAddMore: Bool { isPro || items.count < Store.freeLimit }

    func add(_ item: Plant) {
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: Plant) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Plant) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Plant].self, from: data) {
            items = decoded
        } else {
            items = [
        Plant(plantName: "Honeycrisp Apple", variety: "Honeycrisp", ripenWindow: "Late Sept", notes: ""),
        Plant(plantName: "Duke Blueberry", variety: "Duke", ripenWindow: "Mid July", notes: ""),
        Plant(plantName: "Bartlett Pear", variety: "Bartlett", ripenWindow: "Late Aug", notes: "")
            ]
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
