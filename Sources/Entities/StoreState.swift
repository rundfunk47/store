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

extension StoreState: Equatable where T: Equatable {
    public static func == (lhs: StoreState<T>, rhs: StoreState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true
        case (.loading, .loading):
            return true
        case (.loaded(let lhsValue), .loaded(let rhsValue)):
            return lhsValue == rhsValue
        case (.errored(let lhsError), .errored(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
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
