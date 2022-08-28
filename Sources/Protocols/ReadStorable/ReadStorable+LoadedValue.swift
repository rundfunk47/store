import Foundation

public extension ReadStorable {
    var loadedValue: T? {
        get {
            return state.loadedValue
        }
    }
}
