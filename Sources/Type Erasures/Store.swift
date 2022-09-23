import Foundation
import Combine
import SwiftUI

// MARK: - Abstract base class
fileprivate class _AnyStoreBase<T>: Storable {
    var state: StoreState<T> {
        get {
            fatalError("must override")
        } set {
            fatalError("must override")
        }
    }
    
    func set(_ value: T) {
        fatalError("must override")
    }
    
    func fetch() {
        fatalError("must override")
    }
    
    var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        fatalError("must override")
    }
    
    var objectWillChange: ObservableObjectPublisher {
        fatalError("must override")
    }
    
    init() {
        guard type(of: self) != _AnyStoreBase.self else {
            fatalError("_AnyStoreBase<T> instances can not be created; create a subclass instance instead")
        }
    }
}

// MARK: - Box container class
fileprivate final class _AnyStoreBox<Base: Storable>: _AnyStoreBase<Base.T> {
    var base: Base
    init(_ base: Base) { self.base = base }

    override var state: StoreState<Base.T> {
        get {
            return base.state
        } set {
            base.state = newValue
        }
    }
    
    override func set(_ value: Base.T) {
        return base.set(value)
    }
    
    override func fetch() {
        return base.fetch()
    }
    
    override var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        return base.objectDidChange
    }
    
    override var objectWillChange: ObservableObjectPublisher {
        return base.objectWillChange as! ObservableObjectPublisher
    }
}

// MARK: - AnyStore Wrapper
@propertyWrapper public final class Store<T>: Storable, Subscribable {
    public var state: StoreState<T> {
        get {
            box.state
        } set {
            box.state = newValue
        }
    }
    
    public func set(_ value: T) {
        box.set(value)
    }
    
    public func fetch() {
        box.fetch()
    }
    
    private let box: _AnyStoreBase<T>
    public init<Base: Storable>(_ base: Base) where Base.T == T {
        box = _AnyStoreBox(base)
    }
        
    public var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        get {
            return box.objectDidChange
        }
    }
    
    public var objectWillChange: ObservableObjectPublisher {
        get {
            return box.objectWillChange
        }
    }

    var cancellable: [String: AnyCancellable] = [:]

    func subscribe<EnclosingType: ObservableObject>(
        from: EnclosingType,
        storageKeyPath: AnyKeyPath
    ) {
        Self.subscribe(
            instance: from,
            storageKeyPath: storageKeyPath
        )
    }
    
    private static func subscribe<EnclosingType: ObservableObject>(
        instance: EnclosingType,
        storageKeyPath: AnyKeyPath
    ) {
        let store = instance[keyPath: storageKeyPath] as! ReadStore<T>
        store.subscribe(from: instance)
    }
    
    func subscribe(from instance: any ObservableObject) {
        let key = "\(ObjectIdentifier(instance).hashValue)+\(ObjectIdentifier(self).hashValue)"

        if self.cancellable[key] == nil {
            self.cancellable[key] = self.objectWillChange.sink { [weak instance] in

                if let instance = instance {
                    if Thread.isMainThread {
                        (instance.objectWillChange as! ObservableObjectPublisher).send()
                    } else {
                        DispatchQueue.main.sync {
                            (instance.objectWillChange as! ObservableObjectPublisher).send()
                        }
                    }
                } else {
                    self.cancellable[key] = nil
                }
            }
        }
    }
    
    public static subscript<EnclosingType: ObservableObject>(
        _enclosingInstance instance: EnclosingType,
        wrapped wrappedKeyPath: KeyPath<EnclosingType, T>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Store>
    ) -> T {
        get {
            Self.subscribe(instance: instance, storageKeyPath: storageKeyPath)
            
            let store = instance[keyPath: storageKeyPath]
            
            guard let loadedValue = store.loadedValue else {
                fatalError("Not loaded!")
            }
            
            return loadedValue
        }
        set {
            let store = instance[keyPath: storageKeyPath]
            DispatchQueue.main.async {
                store.loadedValue = newValue
            }
        }
    }

    public static subscript<EnclosingType: ObservableObject>(
        _enclosingInstance instance: EnclosingType,
        projected wrappedKeyPath: ReferenceWritableKeyPath<EnclosingType, Binding<T>>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Store>
    ) -> Binding<T> {
        get {
            Self.subscribe(instance: instance, storageKeyPath: storageKeyPath)
            
            return Binding.init {
                let store = instance[keyPath: storageKeyPath]
                
                return store.loadedValue!
            } set: { newValue in
                let store = instance[keyPath: storageKeyPath]
                
                DispatchQueue.main.async {
                    store.loadedValue = newValue
                }
            }
        }
        @available(*, unavailable, message: "Can't change binding") set {
            fatalError()
        }
    }

    @available(*, unavailable,
        message: "@Store is only available on properties of classes"
    )
    
    public var projectedValue: Binding<T> {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable,
        message: "@Store is only available on properties of classes"
    )
    public var wrappedValue: T {
        get { fatalError() }
        set { fatalError() }
    }
}


public extension Storable {
    func eraseToAnyStore() -> Store<T> {
        return Store(self)
    }
}
