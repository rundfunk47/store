import Foundation

public protocol Fetchable {
    func fetch()
    func fetchIfNeeded()
}
