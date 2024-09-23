import SwiftUI

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