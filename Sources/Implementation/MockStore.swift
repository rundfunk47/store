import Foundation
import Combine

struct MockError: LocalizedError {
    var errorDescription: String? {
        return "Mock error"
    }
}

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
            
            if self.firstError == true {
                self.state = .errored(MockError())
                self.firstError = false
            } else {
                self.state = self.input
            }
        }
    }
    
    public var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        _objectDidChange.eraseToAnyPublisher()
    }
    
    private var _objectDidChange: PassthroughSubject<StoreState<T>, Never> = PassthroughSubject()
        
    private var firstError: Bool
    
    public init(_ input: StoreState<T>, firstError: Bool = false) {
        self.input = input
        self.state = .initial
        self.firstError = firstError
    }
}
