import Foundation

public enum StoreState<T> {
    case errored(Error)
    case initial
    case loading
    case loaded(_ value: T)
    
    public var loadedValue: T? {
        switch self {
        case .loaded(let value):
            return value
        default:
            return nil
        }
    }
}

public extension StoreState {
    subscript<U>(keyPath: KeyPath<T, U>) -> StoreState<U> {
        switch self {
        case .initial:
            return .initial
        case .loading:
            return .loading
        case .errored(let error):
            return .errored(error)
        case .loaded(let value):
            return .loaded(value[keyPath: keyPath])
        }
    }
}
