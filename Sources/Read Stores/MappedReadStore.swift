import Foundation
import Combine

fileprivate struct DummyError: Error {
    
}

class MappedReadStore<T, Base: ReadStorable>: ReadStorable {
    var state: StoreState<T> {
        willSet {
            self.objectWillChange.send()
        }
        didSet {
            self._objectDidChange.send(state)
        }
    }
        
    func fetch() {
        base.fetch()
    }
    
    private var _objectDidChange: PassthroughSubject<StoreState<T>, Never> = PassthroughSubject()

    var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        _objectDidChange.eraseToAnyPublisher()
    }

    var objectWillChange: ObservableObjectPublisher {
        base.objectWillChange as! ObservableObjectPublisher
    }

    var base: Base
    
    var cancellable: AnyCancellable!
    
    static func calculateState(baseState: StoreState<Base.T>, transform: @escaping (Base.T) throws -> T) -> StoreState<T> {
        switch baseState {
        case .initial:
            return .initial
        case .loading:
            return  .loading
        case .loaded(let value):
            do {
                return .loaded(try transform(value))
            } catch {
                return .errored(error)
            }
        case .refreshing(let value):
            do {
                return .refreshing(try transform(value))
            } catch {
                return .errored(error)
            }
        case .errored(let error):
            return .errored(error)
        }
    }
    
    init(_ base: Base, _ transform: @escaping (Base.T) throws -> T) {
        self.base = base
        self.state = Self.calculateState(baseState: base.state, transform: transform)
        
        self.cancellable = base.objectDidChange.sink(receiveValue: { [weak self] baseState in
            self?.state = Self.calculateState(baseState: baseState, transform: transform)
        })
    }
}

public extension ReadStorable {
    func map<U>(_ transform: @escaping (T) throws -> U) -> ReadStore<U> {
        return MappedReadStore(self, transform).eraseToAnyReadStore()
    }
}
