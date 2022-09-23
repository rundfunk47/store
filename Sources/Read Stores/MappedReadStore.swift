import Foundation
import Combine

fileprivate struct DummyError: Error {
    
}

class MappedReadStore<T, Base: ReadStorable>: ReadStorable {
    var state: StoreState<T> {
        willSet {
            self.objectWillChange.send()
        }
        didSet {
            self._objectDidChange.send(state)
        }
    }
        
    func fetch() {
        base.fetch()
    }
    
    public var _objectDidChange: PassthroughSubject<StoreState<T>, Never> = PassthroughSubject()

    var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        _objectDidChange.eraseToAnyPublisher()
    }

    var objectWillChange: ObservableObjectPublisher {
        base.objectWillChange as! ObservableObjectPublisher
    }

    var base: Base
    var transform: (Base.T) throws -> T
    
    var cancellable: AnyCancellable!
    
    init(_ base: Base, _ transform: @escaping (Base.T) throws -> T) {
        self.base = base
        self.transform = transform
        self.state = .initial
        
        self.cancellable = base.objectDidChange.sink(receiveValue: { [weak self] baseState in
            switch baseState {
            case .initial:
                self?.state = .initial
            case .loading:
                self?.state = .loading
            case .loaded(let value):
                do {
                    self?.state = .loaded(try transform(value))
                } catch {
                    self?.state = .errored(error)
                }
            case .errored(let error):
                self?.state = .errored(error)
            }
        })
    }
}

public extension ReadStorable {
    func map<U>(_ transform: @escaping (T) throws -> U) -> ReadStore<U> {
        return MappedReadStore(self, transform).eraseToAnyReadStore()
    }
}
