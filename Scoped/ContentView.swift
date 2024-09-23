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
            
            PayloadCalculatorView()
                .tabItem {
                    Label("Payload Calc", systemImage: "function")
                }
        }
        .onAppear {
            viewModel.fetchLaunches()
            viewModel.fetchRockets()
        }
    }
}

struct PayloadCalculatorView: View {
    @State private var thrust: Double = 1000000 // Default thrust in Newtons
    @State private var altitude: Double = 400000 // Default altitude in meters
    @State private var payloadCapacity: Double = 0
    
    var body: some View {
        Form {
            Section(header: Text("Input Parameters")) {
                HStack {
                    Text("Thrust (N):")
                    Slider(value: $thrust, in: 100000...10000000, step: 100000)
                    Text("\(Int(thrust))")
                }
                HStack {
                    Text("Orbit Altitude (m):")
                    Slider(value: $altitude, in: 200000...1000000, step: 10000)
                    Text("\(Int(altitude))")
                }
            }
            
            Section(header: Text("Calculated Payload Capacity")) {
                Text("\(payloadCapacity, specifier: "%.2f") kg")
                    .font(.headline)
            }
            
            Button("Calculate") {
                payloadCapacity = ObjectiveCUtilities.calculatePayloadCapacity(thrust, orbitAltitude: altitude)
            }
        }
        .navigationTitle("Payload Calculator")
    }
}

#Preview {
    ContentView()
}
