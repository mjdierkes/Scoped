import Foundation
import Combine

class LaunchesViewModel: ObservableObject {
    @Published var launches: [Launch] = []
    @Published var filteredLaunches: [Launch] = []
    @Published var upcomingLaunches: [Launch] = []
    @Published var favoriteLaunches: Set<String> = []
    @Published var rockets: [Rocket] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var filterSuccess: Bool?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadFavorites()
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
                self?.upcomingLaunches = launches.filter { $0.upcoming }
            }
            .store(in: &cancellables)
    }
    
    func fetchRockets() {
        guard let url = URL(string: "https://api.spacexdata.com/v4/rockets") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Rocket].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch rockets: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] rockets in
                self?.rockets = rockets
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
    
    func toggleFavorite(for launchId: String) {
        if favoriteLaunches.contains(launchId) {
            favoriteLaunches.remove(launchId)
        } else {
            favoriteLaunches.insert(launchId)
        }
        saveFavorites()
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteLaunches) {
            UserDefaults.standard.set(encoded, forKey: "FavoriteLaunches")
        }
    }
    
    private func loadFavorites() {
        if let savedFavorites = UserDefaults.standard.data(forKey: "FavoriteLaunches"),
           let decodedFavorites = try? JSONDecoder().decode(Set<String>.self, from: savedFavorites) {
            favoriteLaunches = decodedFavorites
        }
    }
    
    func getLaunchStatistics() -> (total: Int, successful: Int, failed: Int) {
        let total = launches.count
        let successful = launches.filter { $0.success == true }.count
        let failed = launches.filter { $0.success == false }.count
        return (total, successful, failed)
    }
}