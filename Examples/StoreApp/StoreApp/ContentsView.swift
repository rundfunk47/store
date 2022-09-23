//
//  ContentView.swift
//  Store
//
//  Created by Narek Mailian on 2022-09-08.
//

import SwiftUI
import Store

class ContentsViewModel: ObservableObject {
    @ReadStore var contents: [ContentViewModel]
    
    init(stores: Stores) {
        self._contents = stores.namesStore.map({ ids in
            ids.map { id in
                ContentViewModel(id: id, stores: stores)
            }
        })
    }
}

class ContentViewModel: ObservableObject {
    let id: Int
    @ReadStore var name: String
    
    init(id: Int, stores: Stores) {
        self.id = id
        self._name = stores.name(id: id)
    }
}

struct ContentsView<ViewModel: ContentsViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        Self._printChanges()
        
        return Group {
            switch viewModel.presentationState {
            case .loaded:
                ForEach(viewModel.contents, id: \.id) {
                    Text($0.name)
                }
            case .loading:
                ProgressView()
            case .errored(let error):
                Text(error.localizedDescription)
            }
        }.onAppear {
            viewModel.load()
        }
    }
}

struct ContentsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentsView(
            viewModel: ContentsViewModel(
                stores: Stores()
            )
        )
    }
}
