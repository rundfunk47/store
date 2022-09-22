//
//  StoreApp.swift
//  Store
//
//  Created by Narek Mailian on 2022-09-08.
//

import SwiftUI
import Store

@main
struct StoreApp: App {
    var stores = Stores()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel(stores: stores))
        }
    }
}

class Stores {
    var nameStore: ReadStore<String>
    
    init() {
        self.nameStore = MockStore(.loaded("Hi!")).eraseToAnyReadStore()
    }
}
