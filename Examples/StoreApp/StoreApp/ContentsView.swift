//
//  ContentView.swift
//  Store
//
//  Created by Narek Mailian on 2022-09-08.
//

import SwiftUI
import Store

class ContentsViewModel: ObservableObject {
    @ReadStore var name: String
    //@ReadStore var title: String

    init(stores: Stores) {
        self._name = stores.nameStore
        //self._title = stores.titleStore
    }
}

struct ContentsView<ViewModel: ContentsViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            Group {
                switch viewModel.presentationState {
                case .loaded, .refreshing:
                    List {
                        Text(viewModel.name)
                        //Text(viewModel.title)
                    }
                case .loading:
                    ProgressView()
                case .errored(let error):
                    VStack {
                        Text(error.localizedDescription)
                        Button("Retry") {
                            viewModel.load()
                        }
                    }
                }
            }.onAppear {
                viewModel.load()
            }.toolbar {
                ToolbarItem {
                    Button("Reload") {
                        viewModel.reload()
                    }
                }
            }
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
