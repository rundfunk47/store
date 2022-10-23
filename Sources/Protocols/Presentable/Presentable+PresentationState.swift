import Foundation

public extension ObservableObject {
    var presentationState: PresentationState {
        if let store = self as? (any ReadStorable) {
            return store.readStorablePresentationState
        } else {
            let stores = Mirror(reflecting: self)
                .children
                .compactMap { $0.value as? (any ReadStorable) }
                .map { $0.readStorablePresentationState }

            return stores.presentationState
        }
    }
}

private extension ReadStorable {
    var readStorablePresentationState: PresentationState {
        switch state {
        case .initial, .loading:
            return .loading
        case .errored(let error):
            return .errored(error)
        case .loaded:
            return .loaded
        case .refreshing:
            return .refreshing
        }
    }
}
