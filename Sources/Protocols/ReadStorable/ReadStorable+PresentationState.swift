import Foundation
/*
public extension ReadStorable {
    var presentationState: PresentationState {
        switch state {
        case .initial, .loading:
            return .loading
        case .errored(let error):
            return .errored(error)
        case .loaded(let thing):
            if let thing = thing as? PresentationStateProviding {
                return thing.presentationState
            } else if let thing = thing as? (any ObservableObject) {
                return thing.presentationState
            } else if let thing = thing as? (any Sequence) {
                let a = thing.compactMap { element in
                    (element as? (any ObservableObject))?.presentationState
                }
                
                let b = thing.compactMap { element in
                    (element as? (any PresentationStateProviding))?.presentationState
                }
                
                return (a + b).presentationState
            } else {
                return .loaded
            }
        }
    }
}
*/
