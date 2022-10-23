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

    init() {
        nameStore = MockStore(.loaded("Hello world!")).eraseToAnyReadStore()
    }
}
