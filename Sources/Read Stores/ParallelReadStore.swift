import Foundation
import Combine

fileprivate struct DummyError: Error {
    
}

public class ParallelReadStore<A: ReadStorable, B: ReadStorable, Output>: ReadStorable {
    static func calculateState(
        aState: StoreState<A.T>,
        bState: StoreState<B.T>,
        transform: @escaping (A.T, B.T) throws -> T
    ) -> StoreState<Output> {
        switch aState {
        case .initial:
            return .initial
        case .loading:
            return .loading
        case .loaded(let aValue):
            switch bState {
            case .initial:
                return .initial
            case .loading:
                return .loading
            case .loaded(let bValue):
                do {
                    return .loaded(try transform(aValue, bValue))
                } catch {
                    return .errored(error)
                }
            case .errored(let error):
                return .errored(error)
            }
        case .errored(let error):
            return .errored(error)
        }
    }
    
    public var state: StoreState<Output> {
        Self.calculateState(aState: a.state, bState: b.state, transform: transform)
    }
        
    public func fetch() {
        a.fetch()
        b.fetch()
    }
    
    public var objectDidChange: AnyPublisher<StoreState<Output>, Never>

    var a: A
    var b: B
    var transform: (A.T, B.T) throws -> T
    
    var aObjectWillChangeCancellable: AnyCancellable! = nil
    var bObjectWillChangeCancellable: AnyCancellable! = nil
    
    func setupCancellables() {
        aObjectWillChangeCancellable = a.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        
        bObjectWillChangeCancellable = b.objectWillChange.sink { [weak self]  _ in
            self?.objectWillChange.send()
        }
    }
    
    public init(_ a: A, _ b: B, _ transform: @escaping (A.T, B.T) throws -> Output) {
        self.a = a
        self.b = b
        self.transform = transform
        
        self.objectDidChange = Publishers.CombineLatest(a.objectDidChange, b.objectDidChange).map { tuple in
            return Self.calculateState(aState: tuple.0, bState: tuple.1, transform: transform)
        }.eraseToAnyPublisher()
        
        self.setupCancellables()
    }
}
