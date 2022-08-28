import Foundation

protocol Subscribable {
    func subscribe<EnclosingType: ObservableObject>(
        from: EnclosingType,
        storageKeyPath: AnyKeyPath
    )
}
