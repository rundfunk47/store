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
        get {
            base.state[keyPath]
        } set {
            switch newValue {
            case .initial:
                self.base.state = .initial
            case .loading:
                self.base.state = .loading
            case .loaded(let value):
                self.set(value)
            case .errored(let error):
                self.base.state = .errored(error)
            }
        }
    }
    
    public func fetch() {
        base.fetch()
    }
    
    public var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        base.objectDidChange.map { [weak self] state in
            guard let self = self else { return .errored(DummyError()) }
            return state[self.keyPath]
        }.eraseToAnyPublisher()
    }
    
    public var objectWillChange: ObservableObjectPublisher {
        base.objectWillChange as! ObservableObjectPublisher
    }
    
    var base: Base
    var keyPath: WritableKeyPath<Base.T, T>
    
    init(_ base: Base, keyPath: WritableKeyPath<Base.T, T>) {
        self.base = base
        self.keyPath = keyPath
    }
}

public extension Storable {
    func map<U>(_ keyPath: WritableKeyPath<T, U>) -> Store<U> {
        return KeyPathMappedStore(self, keyPath: keyPath).eraseToAnyStore()
    }
}
