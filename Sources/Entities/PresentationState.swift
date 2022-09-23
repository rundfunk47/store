import Foundation

public enum PresentationState {
    case errored(Error)
    case loading
    case loaded
}

extension Collection where Element == PresentationState {
    public var presentationState: PresentationState {
        for element in self {
            switch element {
            case .loading:
                return .loading
            case .errored(let error):
                return .errored(error)
            case .loaded:
                break
            }
        }
        
        return .loaded
    }
}
