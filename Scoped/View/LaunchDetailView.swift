import SwiftUI

struct LaunchDetailView: View {
    let launch: Launch
    @ObservedObject var viewModel: LaunchesViewModel
    @State private var showWebView = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: launch.links.patch.large ?? "")) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(systemName: "photo")
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                
                Text(launch.name)
                    .font(.title)
                
                Text(formattedDate(launch.date_utc))
                
                Text("Success: \(launch.success == true ? "Yes" : launch.success == false ? "No" : "Unknown")")
                    .foregroundColor(launch.success == true ? .green : launch.success == false ? .red : .gray)
                
                if let details = launch.details {
                    Text("Details:")
                        .font(.headline)
                    Text(details)
                }
                
                if let rocket = viewModel.rockets.first(where: { $0.id == launch.rocket }) {
                    Text("Rocket:")
                        .font(.headline)
                    Text(rocket.name)
                    Text(rocket.description)
                        .font(.subheadline)
                }
                
                if let webcast = launch.links.webcast {
                    Button("Watch Webcast") {
                        showWebView = true
                    }
                    .buttonStyle(.borderedProminent)
                    .sheet(isPresented: $showWebView) {
                        WebView(url: URL(string: webcast)!)
                    }
                }
                
                Button(action: {
                    viewModel.toggleFavorite(for: launch.id)
                }) {
                    Label(
                        viewModel.favoriteLaunches.contains(launch.id) ? "Remove from Favorites" : "Add to Favorites",
                        systemImage: viewModel.favoriteLaunches.contains(launch.id) ? "star.fill" : "star"
                    )
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .navigationTitle("Launch Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}