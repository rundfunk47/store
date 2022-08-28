import Foundation
import Combine

#warning("use switch to latest...")
class ChainedReadStore<T, Base: ReadStorable>: ReadStorable {
    var cancellable: AnyCancellable?
    var innerWillChangeCancellable: AnyCancellable?
    var innerDidChangeCancellable: AnyCancellable?

    var state: StoreState<T>
    
    func fetch() {
        base.fetch()
    }

    var _objectDidChange: PassthroughSubject<StoreState<T>, Never>
    var objectWillChange: ObservableObjectPublisher
    var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        _objectDidChange.eraseToAnyPublisher()
    }

    var base: Base
    var transform: (Base.T) -> ReadStore<T>
        
    func switching(state: StoreState<Base.T>) {
        switch state {
        case .loading:
            innerDidChangeCancellable = nil
            self.objectWillChange.send()
            self.state = .loading
            self._objectDidChange.send(.loading)
        case .errored(let error):
            innerDidChangeCancellable = nil
            self.objectWillChange.send()
            self.state = .errored(error)
            self._objectDidChange.send(.errored(error))
        case .initial:
            innerDidChangeCancellable = nil
            self.objectWillChange.send()
            self.state = .initial
            self._objectDidChange.send(.initial)
        case .loaded(let value):
            let newStore = self.transform(value)
            
            innerWillChangeCancellable = newStore.objectWillChange.sink(receiveValue: { [weak self] _ in
                self?.objectWillChange.send()
            })
            
            innerDidChangeCancellable = newStore.objectDidChange.sink { [weak self] _ in
                self?.state = newStore.state
                self?._objectDidChange.send(newStore.state)
            }
            
            self.objectWillChange.send()
            self.state = newStore.state
            newStore.fetchIfNeeded()
            self._objectDidChange.send(newStore.state)
        }
    }
    
    init(_ base: Base, _ transform: @escaping (Base.T) -> ReadStore<T>) {
        self.base = base
        self.transform = transform
        self._objectDidChange = PassthroughSubject<StoreState<T>, Never>()
        self.objectWillChange = ObservableObjectPublisher()
        
        switch base.state {
        case .loading:
            self.state = .loading
        case .errored(let error):
            self.state = .errored(error)
        case .initial:
            self.state = .initial
        case .loaded(let value):
            let newStore = self.transform(value)
            self.state = newStore.state

            innerWillChangeCancellable = newStore.objectWillChange.sink(receiveValue: { [weak self] _ in
                self?.objectWillChange.send()
            })
            
            innerDidChangeCancellable = newStore.objectDidChange.sink { [weak self] _ in
                self?.state = newStore.state
                self?._objectDidChange.send(newStore.state)
            }
            
            newStore.fetchIfNeeded()
        }
        
        cancellable = base.objectDidChange.sink { [weak self] _ in
            guard let self = self else { return }
            self.switching(state: self.base.state)
        }
    }
}

public extension ReadStorable {
    func chainWith<U>(_ transform: @escaping (T) -> ReadStore<U>) -> ReadStore<U> {
        return ChainedReadStore(self, transform).eraseToAnyReadStore()
    }
    
    func chainWithStore<U>(_ transform: @escaping (T) -> Store<U>) -> Store<U> {
        return ChainedStore(self, transform).eraseToAnyStore()
    }
}
