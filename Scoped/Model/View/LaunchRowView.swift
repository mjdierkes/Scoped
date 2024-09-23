import SwiftUI

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
                Text(formattedDate(launch.date_utc))
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