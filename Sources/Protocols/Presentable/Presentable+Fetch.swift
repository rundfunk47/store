import Foundation

public extension ObservableObject {
    func fetch() {
        let allStores = Array(Mirror(reflecting: self).children).compactMap { $0.value as? Fetchable }
        
        for store in allStores {
            store.fetchIfNeeded()
        }
    }
    
    private subscript(checkedMirrorDescendant key: String) -> Any {
        return Mirror(reflecting: self).descendant(key)!
    }
    
    func subscribe() {
        let children = Mirror(reflecting: self).children
        
        for child in children {
            guard let thing = child.value as? Subscribable else { continue }

            let kp = \Self.[checkedMirrorDescendant: child.label!]
            
            thing.subscribe(
                from: self,
                storageKeyPath: kp
            )
        }
    }
}
