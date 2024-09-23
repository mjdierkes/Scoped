import SwiftUI
import Charts

struct MissionControlView: View {
    @ObservedObject var viewModel: LaunchesViewModel
    @State private var countdownTime = 600 // 10 minutes in seconds
    @State private var isCountdownRunning = false
    @State private var selectedRocket = 0
    @State private var thrust = 50.0
    @State private var isLaunchEnabled = false
    @State private var missionStatus = "Preparing"
    @State private var showLaunchGraph = false
    @State private var altitudeData: [AltitudePoint] = []
    @State private var currentTime = 0
    @State private var nasaImages: [NASAImage] = []
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Countdown Timer
                    Text("T-\(timeString(time: countdownTime))")
                        .font(.largeTitle)
                        .onReceive(timer) { _ in
                            if isCountdownRunning && countdownTime > 0 {
                                countdownTime -= 1
                            }
                        }
                    
                    // Start/Stop Countdown
                    Button(isCountdownRunning ? "Abort Countdown" : "Start Countdown") {
                        isCountdownRunning.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    // Rocket Selection
                    Picker("Select Rocket", selection: $selectedRocket) {
                        ForEach(0..<viewModel.rockets.count, id: \.self) { index in
                            Text(viewModel.rockets[index].name).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Thrust Control
                    VStack {
                        Text("Thrust: \(Int(thrust))%")
                        Slider(value: $thrust, in: 0...100, step: 1)
                    }
                    
                    // Launch Enable Switch
                    Toggle("Enable Launch", isOn: $isLaunchEnabled)
                    
                    // Launch Button
                    Button("Launch") {
                        missionStatus = "Launching"
                        showLaunchGraph = true
                        simulateLaunch()
                    }
                    .disabled(!isLaunchEnabled)
                    .buttonStyle(.borderedProminent)
                    
                    // Mission Status
                    Text("Mission Status: \(missionStatus)")
                        .font(.headline)
                    
                    // Launch Graph
                    if showLaunchGraph {
                        VStack {
                            Text("Launch Altitude Graph")
                                .font(.headline)
                            Chart(altitudeData.prefix(currentTime)) { point in
                                LineMark(
                                    x: .value("Time", point.time),
                                    y: .value("Altitude", point.altitude)
                                )
                            }
                            .frame(height: 200)
                            .padding()
                            .animation(.easeInOut, value: currentTime)
                            .onReceive(timer) { _ in
                                if currentTime < altitudeData.count {
                                    currentTime += 1
                                }
                            }
                        }
                    }
                    
                    // NASA Images Grid
                    Text("NASA Image Gallery")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(nasaImages) { image in
                            AsyncImage(url: URL(string: image.url)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 150)
                                        .clipped()
                                case .failure(_):
                                    Image(systemName: "photo")
                                        .frame(height: 150)
                                case .empty:
                                    ProgressView()
                                        .frame(height: 150)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Mission Control")
            .onAppear {
                fetchNASAImages()
            }
        }
    }
    
    func simulateLaunch() {
        altitudeData.removeAll()
        currentTime = 0
        for i in 0...60 {
            let altitude = Double(i) * 10 * (1 + Double.random(in: -0.1...0.1))
            altitudeData.append(AltitudePoint(time: i, altitude: altitude))
        }
    }
    
    func fetchNASAImages() {
        guard let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&count=10") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let decodedData = try JSONDecoder().decode([NASAImage].self, from: data)
                DispatchQueue.main.async {
                    self.nasaImages = decodedData
                }
            } catch {
                print("Error decoding NASA API response: \(error)")
            }
        }.resume()
    }
}

struct AltitudePoint: Identifiable {
    let id = UUID()
    let time: Int
    let altitude: Double
}

struct NASAImage: Codable, Identifiable {
    let id = UUID()
    let url: String
    let title: String
}