import Foundation
import Combine

fileprivate struct DummyError: Error {
    
}

public class KeyPathMappedStore<T, Base: Storable>: Storable {
    public func set(_ value: T) {
        switch base.state {
        case .errored, .initial, .loading:
            fatalError()
        case .loaded(let baseValue):
            var newBaseValue = baseValue
            newBaseValue[keyPath: keyPath] = value
            self.base.set(newBaseValue)
        }
    }

    public var state: StoreState<T> {
        didSet {
            self._objectDidChange.send(state)
        }
        willSet {
            self.objectWillChange.send()
        }
    }
    
    public func fetch() {
        base.fetch()
    }
    
    private let _objectDidChange = PassthroughSubject<StoreState<T>, Never>()
    
    public var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        _objectDidChange.eraseToAnyPublisher()
    }
    
    private var cancellable: AnyCancellable! = nil
    
    public var objectWillChange: ObservableObjectPublisher {
        base.objectWillChange as! ObservableObjectPublisher
    }
    
    var base: Base
    var keyPath: WritableKeyPath<Base.T, T>
    
    static func calculateState(state: StoreState<Base.T>, keyPath: WritableKeyPath<Base.T, T>) -> StoreState<T> {
        switch state {
        case .initial:
            return .initial
        case .loading:
            return  .loading
        case .loaded(let value):
            let val = value[keyPath: keyPath]
            return .loaded(val)
        case .errored(let error):
            return .errored(error)
        }
    }
    
    init(_ base: Base, keyPath: WritableKeyPath<Base.T, T>) {
        self.base = base
        self.keyPath = keyPath
        self.state = Self.calculateState(state: base.state, keyPath: keyPath)

        self.cancellable = base.objectDidChange.sink(receiveValue: { [weak self] state in
            self?.state = Self.calculateState(state: state, keyPath: keyPath)
        })
    }
}

public extension Storable {
    func map<U>(_ keyPath: WritableKeyPath<T, U>) -> Store<U> {
        return KeyPathMappedStore(self, keyPath: keyPath).eraseToAnyStore()
    }
}
