import Foundation
import Combine

class LaunchesViewModel: ObservableObject {
    @Published var launches: [Launch] = []
    @Published var filteredLaunches: [Launch] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var filterSuccess: Bool?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        $searchText
            .combineLatest($filterSuccess, $launches)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.filterLaunches()
            }
            .store(in: &cancellables)
    }
    
    func fetchLaunches() {
        isLoading = true
        errorMessage = nil
        guard let url = URL(string: "https://api.spacexdata.com/v4/launches") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Launch].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = "Failed to fetch launches: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] launches in
                self?.launches = launches
            }
            .store(in: &cancellables)
    }
    
    private func filterLaunches() {
        filteredLaunches = launches.filter { launch in
            let matchesSearch = searchText.isEmpty || launch.name.lowercased().contains(searchText.lowercased())
            let matchesSuccess = filterSuccess == nil || launch.success == filterSuccess
            return matchesSearch && matchesSuccess
        }
    }
}