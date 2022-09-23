//
//  File.swift
//  
//
//  Created by Narek Mailian on 2022-09-23.
//

import Foundation

public extension ObservableObject {
    /*private subscript(checkedMirrorDescendant key: String) -> Any {
        return Mirror(reflecting: self).descendant(key)!
    }
    */
    /*private func subscribe(from observableObject: (any ObservableObject)?) {
        if let store = self as? (any Subscribable) {
            if let observableObject = observableObject {
                store.subscribe(from: observableObject)
            }

            Task {
                guard let fetched = try? await store.value() else {
                    return
                }
                
                if let thing = fetched as? (any ObservableObject) {
                    thing.subscribe(from: observableObject ?? self)
                } else if let thing = fetched as? (any Sequence) {
                    thing.forEach { element in
                        (element as? (any ObservableObject))?.subscribe(from: observableObject ?? self)
                    }
                }
            }
        } else {
            let allChildren = Mirror(reflecting: self).children

            allChildren.forEach { wrapper in
                if let thing = wrapper.value as? (any ObservableObject) {
                    thing.subscribe(from: observableObject ?? self)
                } else if let thing = wrapper.value as? (any Sequence) {
                    thing.forEach { element in
                        (element as? (any ObservableObject))?.subscribe(from: observableObject ?? self)
                    }
                }
            }
        }
    }
    
    func subscribe() {
        self.subscribe(from: nil)
    }*/
}
