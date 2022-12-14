import Foundation

public enum PresentationState {
    case errored(Error)
    case loading
    case loaded
    case refreshing
}

extension Collection where Element == PresentationState {
    public var presentationState: PresentationState {
        var refreshing: Bool = false
        
        for element in self {
            switch element {
            case .loading:
                return .loading
            case .errored(let error):
                return .errored(error)
            case .loaded:
                continue
            case .refreshing:
                refreshing = true
            }
        }
        
        if refreshing {
            return .refreshing
        } else {
            return .loaded
        }
    }
}
