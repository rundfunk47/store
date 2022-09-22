import Foundation
import Combine

public class PublishedStore<T>: Storable {
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
        cancellable = signal.sink { newValue in
            self.state = .loaded(newValue)
        }
    }
    
    public var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        _objectDidChange.eraseToAnyPublisher()
    }
    
    public var _objectDidChange: PassthroughSubject<StoreState<T>, Never> = PassthroughSubject()
        
    private var cancellable: AnyCancellable!
    private let signal: AnyPublisher<T, Never>
    
    public init(_  input: AnyPublisher<T, Never>) {
        self.state = .initial
        
        self.signal = input
    }
}