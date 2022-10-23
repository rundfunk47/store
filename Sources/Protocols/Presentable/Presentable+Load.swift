import Foundation

extension ObservableObject {
    public func load() {
        
    }
    
    private func load(force: Bool) {
        let allChildren = Mirror(reflecting: self).children

        allChildren.forEach { wrapper in
            if let store = wrapper.value as? (any Subscribable) {
                store.subscribe(from: self)
                store.fetchIfNeeded()
            }
        }
    }
    
    public func reload() {
        self.load()
    }
}
