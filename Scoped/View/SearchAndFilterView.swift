import SwiftUI

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