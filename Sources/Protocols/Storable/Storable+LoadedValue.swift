import Foundation

public extension Storable {
    var loadedValue: T? {
        get {
            return state.loadedValue
        } set {
            self.set(newValue!)
        }
    }
}
