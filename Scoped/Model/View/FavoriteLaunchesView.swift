import SwiftUI

struct FavoriteLaunchesView: View {
    @ObservedObject var viewModel: LaunchesViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.sortedLaunches.filter { viewModel.favoriteLaunches.contains($0.id) }) { launch in
                NavigationLink(destination: LaunchDetailView(launch: launch, viewModel: viewModel)) {
                    LaunchRowView(launch: launch, isFavorite: true)
                }
            }
            .navigationTitle("Favorite Launches")
        }
    }
}