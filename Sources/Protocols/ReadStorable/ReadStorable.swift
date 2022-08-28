import Foundation
import Combine

public protocol ReadStorable: ObservableObject, PresentationStateProviding, Fetchable {
    associatedtype T
    
    var state: StoreState<T> { get }
    func fetch()
    var objectDidChange: AnyPublisher<StoreState<T>, Never> { get }
    func eraseToAnyReadStore() -> ReadStore<T>
    func publishedValue() -> AnyPublisher<T, Error>
    func value() async throws -> T
}
