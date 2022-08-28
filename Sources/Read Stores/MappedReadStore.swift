import Foundation
import Combine

fileprivate struct DummyError: Error {
    
}

class MappedReadStore<T, Base: ReadStorable>: ReadStorable {
    var state: StoreState<T> {
        switch base.state {
        case .initial:
            return .initial
        case .loading:
            return .loading
        case .loaded(let value):
            do {
                return .loaded(try transform(value))
            } catch {
                return .errored(error)
            }
        case .errored(let error):
            return .errored(error)
        }
    }
        
    func fetch() {
        base.fetch()
    }
    
    var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        return base.objectDidChange.map { [weak self] state in
            guard let self = self else { return .errored(DummyError()) }

            switch state {
            case .initial:
                return .initial
            case .loading:
                return .loading
            case .loaded(let value):
                do {
                    return .loaded(try self.transform(value))
                } catch {
                    return .errored(error)
                }
            case .errored(let error):
                return .errored(error)
            }

        }.eraseToAnyPublisher()
    }

    var objectWillChange: ObservableObjectPublisher {
        base.objectWillChange as! ObservableObjectPublisher
    }

    var base: Base
    var transform: (Base.T) throws -> T
    
    init(_ base: Base, _ transform: @escaping (Base.T) throws -> T) {
        self.base = base
        self.transform = transform
    }
}

public extension ReadStorable {
    func map<U>(_ transform: @escaping (T) throws -> U) -> ReadStore<U> {
        return MappedReadStore(self, transform).eraseToAnyReadStore()
    }
}
