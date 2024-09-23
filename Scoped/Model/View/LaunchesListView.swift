import SwiftUI

struct LaunchesListView: View {
    @ObservedObject var viewModel: LaunchesViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                SearchAndFilterView(viewModel: viewModel)
                
                if viewModel.isLoading {
                    ProgressView("Loading launches...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    List(viewModel.filteredLaunches) { launch in
                        NavigationLink(destination: LaunchDetailView(launch: launch, viewModel: viewModel)) {
                            LaunchRowView(launch: launch, isFavorite: viewModel.favoriteLaunches.contains(launch.id))
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("SpaceX Launches")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.fetchLaunches) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}