import Foundation
import Combine

fileprivate struct DummyError: Error {
    
}

class ManyParallelReadStore<T, Base: ReadStorable>: ReadStorable {
    private func calculateState(base: [StoreState<Base.T>]) -> StoreState<T> {
        var all: [Base.T] = []
        
        for state in base {
            switch state {
            case .initial:
                return .initial
            case .loading:
                return .loading
            case .loaded(let value):
                all.append(value)
            case .errored(let error):
                return .errored(error)
            }
        }

        do {
            return .loaded(try transform(all))
        } catch {
            return .errored(error)
        }
    }
    
    var state: StoreState<T> {
        calculateState(base: base.map { $0.state })
    }
        
    func fetch() {
        for base in base {
            base.fetch()
        }
    }
    
    var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        base.map { $0.objectDidChange }.combineLatest().map { [weak self] in
            guard let self = self else { return .errored(DummyError()) }
            return self.calculateState(base: $0)
        }.eraseToAnyPublisher()
    }

    var base: [Base]
    var transform: ([Base.T]) throws -> T
    
    var objectWillChangeCancellable: AnyCancellable! = nil
    
    init<Others: Collection>(_ base: Others, _ transform: @escaping ([Base.T]) throws -> T) where Others.Element == Base {
        self.base = base.map { $0 }
        self.transform = transform
                
        objectWillChangeCancellable = Publishers.MergeMany(base.map { $0.objectWillChange }).sink(receiveValue: { [weak self] _ in
            self?.objectWillChange.send()
        })
    }
}

public extension Collection where Element: ReadStorable {
    func parallel<U>(_ transform: @escaping ([Element.T]) throws -> U) -> ReadStore<U> {
        return ManyParallelReadStore<U, Element>(self, transform).eraseToAnyReadStore()
    }
}

#warning("move me maybe?")
fileprivate extension Publisher {
    /// Projects `self` and a `Collection` of `Publisher`s onto a type-erased publisher that chains `combineLatest` calls on
    /// the inner publishers. This is a variadic overload on Combine’s variants that top out at arity three.
    ///
    /// - parameter others: A `Collection`-worth of other publishers with matching output and failure types to combine with.
    ///
    /// - returns: A type-erased publisher with value events from `self` and each of the inner publishers `combineLatest`’d
    /// together in an array.
    func combineLatest<Others: Collection>(with others: Others)
        -> AnyPublisher<[Output], Failure>
        where Others.Element: Publisher, Others.Element.Output == Output, Others.Element.Failure == Failure {
        let seed = map { [$0] }.eraseToAnyPublisher()

        return others.reduce(seed) { combined, next in
            combined
                .combineLatest(next)
                .map { $0 + [$1] }
                .eraseToAnyPublisher()
        }
    }

    /// Projects `self` and a `Collection` of `Publisher`s onto a type-erased publisher that chains `combineLatest` calls on
    /// the inner publishers. This is a variadic overload on Combine’s variants that top out at arity three.
    ///
    /// - parameter others: A `Collection`-worth of other publishers with matching output and failure types to combine with.
    ///
    /// - returns: A type-erased publisher with value events from `self` and each of the inner publishers `combineLatest`’d
    /// together in an array.
    func combineLatest<Other: Publisher>(with others: Other...)
        -> AnyPublisher<[Output], Failure>
        where Other.Output == Output, Other.Failure == Failure {
        combineLatest(with: others)
    }
}

fileprivate extension Collection where Element: Publisher {
    /// Projects a `Collection` of `Publisher`s onto a type-erased publisher that chains `combineLatest` calls on
    /// the inner publishers. This is a variadic overload on Combine’s variants that top out at arity three.
    ///
    /// - returns: A type-erased publisher with value events from each of the inner publishers `combineLatest`’d
    /// together in an array.
    func combineLatest() -> AnyPublisher<[Element.Output], Element.Failure> {
        switch count {
        case 0:
            return Empty().eraseToAnyPublisher()
        case 1:
            return self[startIndex]
                .combineLatest(with: [Element]())
        default:
            let first = self[startIndex]
            let others = self[index(after: startIndex)...]

            return first
                .combineLatest(with: others)
        }
    }
}
