import Foundation

public extension ReadStorable {
    func fetchIfNeeded() {
        switch self.state {
        case .errored, .initial:
            fetch()
        default:
            break
        }
    }
}
