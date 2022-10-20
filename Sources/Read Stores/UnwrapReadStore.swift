import Foundation
import Combine

class UnwrapReadStore<Base: ReadStorable>: ReadStorable where Base.T: Wrapping {
    public var state: StoreState<Base.T.Wrapped> {
        switch base.state {
        case .errored(let error):
            return .errored(error)
        case .loading:
            return .loading
        case .initial:
            return .initial
        case .refreshing(let wrapped):
            do {
                return .loaded(try wrapped.unwrapWithError())
            } catch {
                return .errored(error)
            }
        case .loaded(let wrapped):
            do {
                return .loaded(try wrapped.unwrapWithError())
            } catch {
                return .errored(error)
            }
        }
    }

    public func fetch() {
        base.fetch()
    }
    
    public var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        return base.objectDidChange.map { state in
            switch state {
            case .errored(let error):
                return .errored(error)
            case .loading:
                return .loading
            case .initial:
                return .initial
            case .refreshing(let wrapped):
                do {
                    return .refreshing(try wrapped.unwrapWithError())
                } catch {
                    return .errored(error)
                }
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

public extension ReadStorable where Self.T: Wrapping {
    func unwrap() -> ReadStore<Self.T.Wrapped> {
        return UnwrapReadStore(self).eraseToAnyReadStore()
    }
}
