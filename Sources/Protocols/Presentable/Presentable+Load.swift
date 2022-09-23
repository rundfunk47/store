import Foundation

extension ObservableObject {
    public func load() {
        self.load(from: nil, force: false)
    }
    
    public func reload() {
        self.load(from: nil, force: true)
    }
    
    func load(from observableObject: (any ObservableObject)? = nil, force: Bool) {
        if let store = self as? (any Subscribable) {
            if let observableObject = observableObject {
                store.subscribe(from: observableObject)
            }

            Task {
                guard let fetched = try? await (force ? store.forceNewValue() : store.value()) else {
                    return
                }

                if let thing = fetched as? (any ObservableObject) {
                    thing.load(from: observableObject ?? self, force: force)
                } else if let thing = fetched as? (any Sequence) {
                    thing.forEach { element in
                        (element as? (any ObservableObject))?.load(from: observableObject ?? self, force: force)
                    }
                }
            }
        } else {
            let allChildren = Mirror(reflecting: self).children

            allChildren.forEach { wrapper in
                if let thing = wrapper.value as? (any ObservableObject) {
                    thing.load(from: observableObject ?? self, force: force)
                } else if let thing = wrapper.value as? (any Sequence) {
                    thing.forEach { element in
                        (element as? (any ObservableObject))?.load(from: observableObject ?? self, force: force)
                    }
                }
            }
        }
    }
}
