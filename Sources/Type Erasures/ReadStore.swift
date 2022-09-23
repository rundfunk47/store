import Foundation
import Combine

// MARK: - Abstract base class
fileprivate class _AnyReadStoreBase<T>: ReadStorable {
    var state: StoreState<T> {
        get {
            fatalError("must override")
        }
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
        guard type(of: self) != _AnyReadStoreBase.self else {
            fatalError("_AnyReadStoreBase<T> instances can not be created; create a subclass instance instead")
        }
    }
}

// MARK: - Box container class
fileprivate final class _AnyReadStoreBox<Base: ReadStorable>: _AnyReadStoreBase<Base.T> {
    var base: Base
    init(_ base: Base) { self.base = base }

    override var state: StoreState<Base.T> {
        get {
            return base.state
        }
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
@propertyWrapper public final class ReadStore<T>: ReadStorable, Subscribable {
    public var state: StoreState<T> {
        get {
            box.state
        }
    }
    
    public func fetch() {
        box.fetch()
    }
    
    private let box: _AnyReadStoreBase<T>
    public init<Base: ReadStorable>(_ base: Base) where Base.T == T {
        box = _AnyReadStoreBox(base)
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
    
    // Used by property wrapper
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
    
    private static func subscribe<EnclosingType: ObservableObject>(
        instance: EnclosingType,
        storageKeyPath: AnyKeyPath
    ) {
        let store = instance[keyPath: storageKeyPath] as! ReadStore<T>
        store.subscribe(from: instance)
    }

    public static subscript<EnclosingType: ObservableObject>(
        _enclosingInstance instance: EnclosingType,
        wrapped wrappedKeyPath: KeyPath<EnclosingType, T>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingType, ReadStore>
    ) -> T {
        Self.subscribe(instance: instance, storageKeyPath: storageKeyPath)

        let store = instance[keyPath: storageKeyPath]
        return store.loadedValue!
    }
    
    @available(*, unavailable,
        message: "@ReadStore is only available on properties of classes"
    )
    
    public var wrappedValue: T {
        get { fatalError() }
    }
}

public extension ReadStorable {
    func eraseToAnyReadStore() -> ReadStore<T> {
        return ReadStore(self)
    }
}

