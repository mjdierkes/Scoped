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
                    Label("Launches", systemImage: "airplane.departure")
                }
            
            FavoriteLaunchesView(viewModel: viewModel)
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
            
            LaunchStatisticsView(viewModel: viewModel)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar")
                }
            
            MissionControlView(viewModel: viewModel)
                .tabItem {
                    Label("Mission Control", systemImage: "slider.horizontal.3")
                }
        }
        .onAppear {
            viewModel.fetchLaunches()
            viewModel.fetchRockets()
        }
    }
}

#Preview {
    ContentView()
}
