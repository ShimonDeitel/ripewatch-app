import XCTest
@testable import Ripewatch

@MainActor
final class RipewatchTests: XCTestCase {
    var store: Store!

    override func setUp() async throws {
        store = Store()
    }

    func testSeedDataLoadsUnderFreeLimit() {
        XCTAssertLessThan(store.items.count, Store.freeLimit)
    }

    func testAddIncreasesCount() {
        let before = store.items.count
        store.add(Plant(plantName: "Test", variety: "Test", ripenWindow: "Test", notes: "Test"))
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testDeleteDecreasesCount() {
        store.add(Plant(plantName: "Test", variety: "Test", ripenWindow: "Test", notes: "Test"))
        let before = store.items.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.items.count, before - 1)
    }

    func testDeleteByItem() {
        let item = Plant(plantName: "Test", variety: "Test", ripenWindow: "Test", notes: "Test")
        store.add(item)
        store.delete(item)
        XCTAssertFalse(store.items.contains(where: { $0.id == item.id }))
    }

    func testCanAddMoreWhenUnderLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreAtLimitWhenFree() {
        for _ in 0..<(Store.freeLimit + 5) {
            store.add(Plant(plantName: "Test", variety: "Test", ripenWindow: "Test", notes: "Test"))
        }
        XCTAssertFalse(store.canAddMore)
    }

    func testProAlwaysCanAddMore() {
        store.isPro = true
        for _ in 0..<(Store.freeLimit + 5) {
            store.add(Plant(plantName: "Test", variety: "Test", ripenWindow: "Test", notes: "Test"))
        }
        XCTAssertTrue(store.canAddMore)
    }

    func testUpdateModifiesItem() {
        let item = Plant(plantName: "Test", variety: "Test", ripenWindow: "Test", notes: "Test")
        store.add(item)
        var updated = item
        store.update(updated)
        XCTAssertEqual(store.items.first(where: { $0.id == item.id })?.id, item.id)
    }
}
