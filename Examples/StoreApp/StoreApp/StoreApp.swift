//
//  StoreApp.swift
//  Store
//
//  Created by Narek Mailian on 2022-09-08.
//

import SwiftUI
import Combine
import Store

@main
struct StoreApp: App {
    var stores = Stores()
    
    var body: some Scene {
        WindowGroup {
            ContentsView(viewModel: ContentsViewModel(stores: stores))
        }
    }
}

class Stores {
    var nameStore: ReadStore<String>
    var titleStore: ReadStore<String>

    init() {
        self.nameStore = CrazyStore().eraseToAnyReadStore()
        self.titleStore = CrazyStore().eraseToAnyReadStore()
    }
}

class CrazyStore: ReadStorable {
    var state: StoreState<String>
    
    var objectDidChange: AnyPublisher<StoreState<String>, Never> {
        _objectDidChange.eraseToAnyPublisher()
    }
    
    var _objectDidChange = PassthroughSubject<StoreState<String>, Never>()

    func fetch() {
        //self.state = .loaded("Hi!")
    }
    
    var timer: Timer!

    deinit {
        timer.invalidate()
    }
    
    init() {
        self.state = .initial
        
        self.timer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 0.5...1.5), repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            
            switch self.state {
            case .loaded:
                self.objectWillChange.send()
                self.state = .initial
                self._objectDidChange.send(self.state)
            case .initial:
                self.objectWillChange.send()
                self.state = .loaded("Hi!")
                self._objectDidChange.send(self.state)
            default:
                break
            }
        })
    }
}
