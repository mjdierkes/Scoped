# Scoped: SpaceX Launch Tracker

Scoped is an iOS app that provides comprehensive information about SpaceX launches, including past missions, upcoming launches, and detailed statistics. Built with SwiftUI, this app offers a user-friendly interface to explore and track SpaceX's space missions.

## Features

- **Launch List**: View a comprehensive list of all SpaceX launches, including past and upcoming missions.
- **Launch Details**: Get detailed information about each launch, including mission patches, success status, and more.
- **Favorites**: Save your favorite launches for quick access.
- **Launch Statistics**: Visualize launch data with interactive charts and graphs.
- **Mission Control**: Experience a simulated mission control interface with countdown timers and launch controls.
- **Payload Calculator**: Calculate theoretical payload capacity based on thrust and orbit altitude.
- **Search and Filter**: Easily find specific launches using search and filter options.

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.5+

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/mjdierkes/Scoped.git
   ```
2. Open the project in Xcode:
   ```
   cd Scoped
   open Scoped.xcodeproj
   ```
3. Build and run the project in Xcode using a simulator or connected device.

## Architecture

Scoped follows the MVVM (Model-View-ViewModel) architecture:

- **Models**: Represent the data structures (e.g., `Launch`, `Rocket`).
- **Views**: SwiftUI views that make up the user interface.
- **ViewModels**: Manage the business logic and data for the views (e.g., `LaunchesViewModel`).

The app also utilizes Combine for reactive programming and SwiftUI Charts for data visualization.

## Key Components

- `ContentView.swift`: The main view that sets up the tab-based navigation.
- `LaunchesListView.swift`: Displays the list of all launches.
- `LaunchDetailView.swift`: Shows detailed information about a specific launch.
- `LaunchStatisticsView.swift`: Presents various charts and statistics about launches.
- `MissionControlView.swift`: Simulates a mission control interface.
- `PayloadCalculatorView.swift`: Calculates theoretical payload capacity.

## Data Source

The app fetches launch and rocket data from the SpaceX API. For more information about the API, visit [SpaceX API Documentation](https://github.com/r-spacex/SpaceX-API).

## Contributing

Contributions to Scoped are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- SpaceX for providing the API and inspiring space enthusiasts worldwide.
- The SwiftUI and Combine frameworks for enabling reactive and declarative UI development.