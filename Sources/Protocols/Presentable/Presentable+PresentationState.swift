import Foundation

public extension ObservableObject {
    var presentationState: PresentationState {
        return [self].presentationState
    }
}

public extension Collection where Element: ObservableObject {
    var presentationState: PresentationState {
        for observableObject in self {
            let allStores = Mirror(reflecting: observableObject).children
            
            let states = allStores.compactMap { wrapper -> PresentationState? in
                guard let thing = wrapper.value as? PresentationStateProviding else { return nil }
                return thing.presentationState
            }
            
            for state in states {
                switch state {
                case .loading:
                    return .loading
                case .errored(let error):
                    return .errored(error)
                case .loaded:
                    break
                }
            }
        }
        
        return .loaded
    }
}
