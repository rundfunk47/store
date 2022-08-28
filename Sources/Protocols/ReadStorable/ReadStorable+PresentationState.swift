import Foundation

public extension ReadStorable {
    var presentationState: PresentationState {
        switch state {
        case .initial, .loading:
            return .loading
        case .errored(let error):
            return .errored(error)
        case .loaded:
            return .loaded
        }
    }
}
