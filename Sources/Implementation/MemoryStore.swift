import Foundation
import Combine

public class MemoryStore<T>: Storable {
    public var state: StoreState<T> {
        willSet {
            self.objectWillChange.send()
        } didSet {
            self._objectDidChange.send(state)
            if let loadedValue = state.loadedValue {
                postSet?(loadedValue)
            }
        }
    }
    
    public func set(_ value: T) {
        self.state = .loaded(value)
    }
    
    public func fetch() {
        
    }
    
    public var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        _objectDidChange.eraseToAnyPublisher()
    }
    
    private let postSet: ((T) -> Void)?
    public var _objectDidChange: PassthroughSubject<StoreState<T>, Never> = PassthroughSubject()
        
    public init(_ input: StoreState<T>, didSet: ((T) -> Void)? = nil) {
        self.state = input
        self.postSet = didSet
    }
}
