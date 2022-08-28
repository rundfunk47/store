import Foundation
import Combine

class UnwrapStore<Base: Storable>: Storable where Base.T: OptionalProtocol {
    func set(_ value: Base.T.Wrapped) {
        base.set(value as! Base.T)
    }
    
    public var state: StoreState<Base.T.Wrapped> {
        get {
            switch base.state {
            case .errored(let error):
                return .errored(error)
            case .loading:
                return .loading
            case .initial:
                return .initial
            case .loaded(let wrapped):
                do {
                    return .loaded(try wrapped.unwrapWithError())
                } catch {
                    return .errored(error)
                }
            }
        } set {
            switch newValue {
            case .errored(let error):
                self.base.state = .errored(error)
            case .loading:
                self.base.state = .loading
            case .initial:
                self.base.state = .initial
            case .loaded(let value):
                self.base.state = .loaded(value as! Base.T)
            }
        }
    }

    public func fetch() {
        base.fetch()
    }
    
    public var objectDidChange: AnyPublisher<StoreState<Base.T.Wrapped>, Never> {
        return base.objectDidChange.map { value in
            switch value {
            case .errored(let error):
                return .errored(error)
            case .loading:
                return .loading
            case .initial:
                return .initial
            case .loaded(let wrapped):
                do {
                    return .loaded(try wrapped.unwrapWithError())
                } catch {
                    return .errored(error)
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public var objectWillChange: ObservableObjectPublisher {
        base.objectWillChange as! ObservableObjectPublisher
    }

    var base: Base

    init(_ base: Base) {
        self.base = base
    }
}

public extension Storable where Self.T: OptionalProtocol {
    func unwrap() -> Store<Self.T.Wrapped> {
        return UnwrapStore(self).eraseToAnyStore()
    }
}
