import Foundation

public extension ObservableObject {
    var presentationState: PresentationState {
        if let store = self as? (any ReadStorable) {
            return store.readStorablePresentationState
        } else {
            let allChildren = Mirror(reflecting: self).children

            let states = allChildren.compactMap { wrapper -> PresentationState? in
                if let thing = wrapper.value as? (any ObservableObject) {
                    return thing.presentationState
                } else if let thing = wrapper.value as? (any Sequence) {
                    return thing.compactMap { element in
                        (element as? (any ObservableObject))?.presentationState
                    }.presentationState
                } else {
                    return nil
                }
            }
            
            return states.presentationState
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
        case .loaded(let thing):
            if let thing = thing as? (any ObservableObject) {
                return thing.presentationState
            } else if let thing = thing as? (any Sequence) {
                return thing.compactMap { element in
                    (element as? (any ObservableObject))?.presentationState
                }.presentationState
            } else {
                return .loaded
            }
        case .refreshing(let thing):
            if let thing = thing as? (any ObservableObject) {
                return thing.presentationState
            } else if let thing = thing as? (any Sequence) {
                return thing.compactMap { element in
                    (element as? (any ObservableObject))?.presentationState
                }.presentationState
            } else {
                return .refreshing
            }
        }
    }
}
