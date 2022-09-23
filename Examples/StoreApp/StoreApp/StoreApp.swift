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
            ContentsView(viewModel: ContentsViewModel(stores: stores))
        }
    }
}

class Stores {
    var namesStore: ReadStore<[Int]>
    
    func name(id: Int) -> ReadStore<String> {
        if id == 0 {
            return MockStore(.loaded("Hi!")).eraseToAnyReadStore()
        } else {
            return MockStore(.loaded("Hello!"), firstError: true).eraseToAnyReadStore()
        }
    }
    
    init() {
        self.namesStore = MockStore(.loaded([0, 1])).eraseToAnyReadStore()
    }
}
