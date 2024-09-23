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
                        NavigationLink(destination: LaunchDetailView(launch: launch)) {
                            LaunchRowView(launch: launch)
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
        .onAppear {
            if viewModel.launches.isEmpty {
                viewModel.fetchLaunches()
            }
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
        }
    }
}

struct LaunchDetailView: View {
    let launch: Launch
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
                
                if let webcast = launch.links.webcast {
                    Button("Watch Webcast") {
                        showWebView = true
                    }
                    .buttonStyle(.borderedProminent)
                    .sheet(isPresented: $showWebView) {
                        WebView(url: URL(string: webcast)!)
                    }
                }
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
