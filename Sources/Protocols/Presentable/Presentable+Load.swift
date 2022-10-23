import Foundation

extension ObservableObject {
    public func load() {
        self.load(force: false)
    }
    
    private func load(force: Bool) {
        let allChildren = Mirror(reflecting: self).children

        allChildren.forEach { wrapper in
            if let store = wrapper.value as? (any Subscribable) {
                store.subscribe(from: self)
                if force {
                    store.fetch()
                } else {
                    store.fetchIfNeeded()
                }
            }
        }
    }
    
    public func reload() {
        self.load(force: true)
    }
}
