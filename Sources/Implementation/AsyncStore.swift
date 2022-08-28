import Foundation
import Combine

public class AsyncStore<T>: ReadStorable {
    private let closure: () async throws -> T
    
    public var state: StoreState<T> {
        willSet {
            if Thread.isMainThread {
                self.objectWillChange.send()
            } else {
                DispatchQueue.main.sync { [weak self] in
                    self?.objectWillChange.send()
                }
            }
        } didSet {
            self._objectDidChange.send(state)
        }
    }
    
    public func fetch() {
        switch self.state {
        case .loading, .loaded:
            return
        default:
            break
        }
        
        // if initial or error:
        
        self.state = .loading
        
        Task {
            do {
                let value = try await closure()
                self.state = .loaded(value)
            } catch {
                self.state = .errored(error)
            }
        }
    }
    
    public var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        _objectDidChange.eraseToAnyPublisher()
    }
    
    public var _objectDidChange: PassthroughSubject<StoreState<T>, Never> = PassthroughSubject()
        
    public init(_ closure: @escaping () async throws -> T) {
        self.state = .initial
        self.closure = closure
    }
}
