//
//  ContentView.swift
//  Store
//
//  Created by Narek Mailian on 2022-09-08.
//

import SwiftUI
import Store

class ContentViewModel: ObservableObject {
    @ReadStore var name: String
    
    init(stores: Stores) {
        self._name = stores.nameStore
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        Group {
            switch viewModel.presentationState {
            case .loaded:
                Text(viewModel.name)
                    .padding()
            case .loading:
                ProgressView()
            case .errored(let error):
                Text(error.localizedDescription)
            }
        }.onAppear {
            viewModel.subscribe()
            viewModel.fetch()
        }
    }
}

/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
*/
