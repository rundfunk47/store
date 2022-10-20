import Foundation
import Combine

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
        case .loaded(let aValue), .refreshing(let aValue):
            switch bState {
            case .initial:
                return .initial
            case .loading:
                return .loading
            case .loaded(let bValue), .refreshing(let bValue):
                do {
                    if aState.isRefreshing || bState.isRefreshing {
                        return .refreshing(try transform(aValue, bValue))
                    } else {
                        return .loaded(try transform(aValue, bValue))
                    }
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
        willSet {
            Task { @MainActor in
                self.objectWillChange.send()
            }
        }
        didSet {
            self._objectDidChange.send(state)
        }
    }
        
    public func fetch() {
        a.fetch()
        b.fetch()
    }
    
    public var objectDidChange: AnyPublisher<StoreState<Output>, Never> {
        _objectDidChange.eraseToAnyPublisher()
    }
    
    private var _objectDidChange: PassthroughSubject<StoreState<T>, Never> = PassthroughSubject()

    var a: A
    var b: B
    var transform: (A.T, B.T) throws -> T
    
    var didChangeCancellable: AnyCancellable! = nil

    public init(_ a: A, _ b: B, _ transform: @escaping (A.T, B.T) throws -> Output) {
        self.a = a
        self.b = b
        self.transform = transform
        self.state = Self.calculateState(aState: a.state, bState: b.state, transform: transform)
        
        didChangeCancellable = Publishers.CombineLatest(a.objectDidChange, b.objectDidChange).map { tuple in
            return Self.calculateState(aState: tuple.0, bState: tuple.1, transform: transform)
        }.sink(receiveValue: { [weak self] newState in
            self?.state = newState
        })
    }
}
