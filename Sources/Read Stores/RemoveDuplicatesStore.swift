//
//  File.swift
//  
//
//  Created by Narek Mailian on 2022-11-14.
//

import Foundation
import Combine
import Store

class RemoveDuplicatesStore<T: Equatable, Base: Storable>: Storable where Base.T == T {
    var cancellables = Set<AnyCancellable>()
    
    var state: StoreState<T> {
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
    
    func set(_ value: T) {
        base.set(value)
    }
        
    func fetch() {
        base.fetch()
    }
    
    private var base: Base

    var _objectDidChange = PassthroughSubject<StoreState<T>, Never>()
    
    var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        _objectDidChange.eraseToAnyPublisher()
    }
    
    var objectWillChange = ObservableObjectPublisher()

    init(_ base: Base) {
        self.base = base
        self.state = base.state
        
        base.objectDidChange.sink { [weak self] _ in
            guard let self = self else { return }
            switch (self.state, base.state) {
            case (.loading, .loading):
                break
            case (.initial, .initial):
                break
            case (.errored(let oldError), .errored(let newError)):
                if oldError.localizedDescription != newError.localizedDescription {
                    self.state = base.state
                }
            case (.loaded(let oldValue), .loaded(let newValue)):
                if oldValue != newValue {
                    self.state = base.state
                }
            default:
                self.state = base.state
            }
        }.store(in: &cancellables)
    }
    
    func setState() {
        
    }
}

class RemoveDuplicatesReadStore<T: Equatable, Base: ReadStorable>: ReadStorable where Base.T == T {
    var cancellables = Set<AnyCancellable>()
    
    var state: StoreState<T> {
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
    
    func fetch() {
        base.fetch()
    }
    
    private var base: Base

    var _objectDidChange = PassthroughSubject<StoreState<T>, Never>()
    
    var objectDidChange: AnyPublisher<StoreState<T>, Never> {
        _objectDidChange.eraseToAnyPublisher()
    }
    
    var objectWillChange = ObservableObjectPublisher()

    init(_ base: Base) {
        self.base = base
        self.state = base.state
        
        base.objectDidChange.sink { [weak self] _ in
            guard let self = self else { return }
            switch (self.state, base.state) {
            case (.loading, .loading):
                break
            case (.initial, .initial):
                break
            case (.errored(let oldError), .errored(let newError)):
                if oldError.localizedDescription != newError.localizedDescription {
                    self.state = base.state
                }
            case (.loaded(let oldValue), .loaded(let newValue)):
                if oldValue != newValue {
                    self.state = base.state
                }
            default:
                self.state = base.state
            }
        }.store(in: &cancellables)
    }
    
    func setState() {
        
    }
}


public extension Storable where T: Equatable {
    func removeDuplicates() -> Store<T> {
        return RemoveDuplicatesStore(self).eraseToAnyStore()
    }
}

public extension ReadStorable where T: Equatable {
    func removeDuplicates() -> ReadStore<T> {
        return RemoveDuplicatesReadStore(self).eraseToAnyReadStore()
    }
}
