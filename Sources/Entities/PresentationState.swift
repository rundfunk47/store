import Foundation

public enum PresentationState {
    case errored(Error)
    case loading
    case loaded
}
