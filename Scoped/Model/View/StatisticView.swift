import SwiftUI

struct StatisticView: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            Text("\(value)")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}