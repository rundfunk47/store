import Foundation
import Combine

public protocol Storable: ReadStorable {
    var state: StoreState<T> { get set }
    func set(_ value: T)
    func asyncSet(_ closure: (T) -> T) async throws
    func eraseToAnyStore() -> Store<T>
}

public extension Storable {
    func asyncSet(_ closure: (T) -> T) async throws {
        let value = try await self.value()
        let newValue = closure(value)
        self.set(newValue)
    }
}
