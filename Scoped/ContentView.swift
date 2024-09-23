//
//  ContentView.swift
//  Scoped
//
//  Created by Mason Dierkes on 9/22/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LaunchesViewModel()
    
    var body: some View {
        TabView {
            LaunchesListView(viewModel: viewModel)
                .tabItem {
                    Label("Launches", systemImage: "rocket")
                }
            
            UpcomingLaunchesView(viewModel: viewModel)
                .tabItem {
                    Label("Upcoming", systemImage: "clock")
                }
            
            FavoriteLaunchesView(viewModel: viewModel)
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
            
            LaunchStatisticsView(viewModel: viewModel)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar")
                }
        }
        .onAppear {
            viewModel.fetchLaunches()
            viewModel.fetchRockets()
        }
    }
}

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

struct UpcomingLaunchesView: View {
    @ObservedObject var viewModel: LaunchesViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.upcomingLaunches) { launch in
                NavigationLink(destination: LaunchDetailView(launch: launch, viewModel: viewModel)) {
                    LaunchRowView(launch: launch, isFavorite: viewModel.favoriteLaunches.contains(launch.id))
                }
            }
            .navigationTitle("Upcoming Launches")
        }
    }
}

struct FavoriteLaunchesView: View {
    @ObservedObject var viewModel: LaunchesViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.launches.filter { viewModel.favoriteLaunches.contains($0.id) }) { launch in
                NavigationLink(destination: LaunchDetailView(launch: launch, viewModel: viewModel)) {
                    LaunchRowView(launch: launch, isFavorite: true)
                }
            }
            .navigationTitle("Favorite Launches")
        }
    }
}

struct LaunchStatisticsView: View {
    @ObservedObject var viewModel: LaunchesViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                let stats = viewModel.getLaunchStatistics()
                StatisticView(title: "Total Launches", value: stats.total)
                StatisticView(title: "Successful Launches", value: stats.successful)
                StatisticView(title: "Failed Launches", value: stats.failed)
            }
            .navigationTitle("Launch Statistics")
        }
    }
}

struct StatisticView: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            Text("\(value)")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}

struct SearchAndFilterView: View {
    @ObservedObject var viewModel: LaunchesViewModel
    
    var body: some View {
        VStack {
            TextField("Search launches", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Picker("Filter by success", selection: $viewModel.filterSuccess) {
                Text("All").tag(nil as Bool?)
                Text("Successful").tag(true as Bool?)
                Text("Failed").tag(false as Bool?)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
        }
    }
}

struct LaunchRowView: View {
    let launch: Launch
    let isFavorite: Bool
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: launch.links.patch.small ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "photo")
            }
            .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(launch.name)
                    .font(.headline)
                Text("Date: \(formattedDate(launch.date_utc))")
                    .font(.subheadline)
                Text("Success: \(launch.success == true ? "Yes" : launch.success == false ? "No" : "Unknown")")
                    .font(.subheadline)
                    .foregroundColor(launch.success == true ? .green : launch.success == false ? .red : .gray)
            }
            
            Spacer()
            
            if isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
    }
}

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
                
                Text("Date: \(formattedDate(launch.date_utc))")
                
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

func formattedDate(_ dateString: String) -> String {
    let inputFormatter = ISO8601DateFormatter()
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "MMM d, yyyy"
    
    if let date = inputFormatter.date(from: dateString) {
        return outputFormatter.string(from: date)
    }
    return dateString
}

#Preview {
    ContentView()
}
