import Foundation

protocol Subscribable {
    associatedtype T

    func subscribe(from instance: any ObservableObject)
    func value() async throws -> T
    func forceNewValue() async throws -> T
    func fetch()
    func fetchIfNeeded()
}
