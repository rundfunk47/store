import Foundation
import Combine

public class MockStore<T>: Storable {
    let input: StoreState<T>
    
    public var state: StoreState<T> {
        willSet {
            self.objectWillChange.send()
        } didSet {
            self._objectDidChange.send(state)
        }
    }
    
    public func set(_ value: T) {
        self.state = .loaded(value)
    }
    
    public func fetch() {
        self.state = .loading

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            self.state = self.input
        }
    }
    
    public var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        _objectDidChange.eraseToAnyPublisher()
    }
    
    public var _objectDidChange: PassthroughSubject<StoreState<T>, Never> = PassthroughSubject()
        
    public init(_ input: StoreState<T>) {
        self.input = input
        self.state = .initial
    }
}
