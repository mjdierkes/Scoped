import Foundation

func formattedDate(_ dateString: String) -> String {
    let inputFormatter = ISO8601DateFormatter()
    inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
    outputFormatter.amSymbol = "AM"
    outputFormatter.pmSymbol = "PM"
    
    if let date = inputFormatter.date(from: dateString) {
        return outputFormatter.string(from: date)
    }
    return "Date unavailable"
}

func timeString(time: Int) -> String {
    let minutes = time / 60
    let seconds = time % 60
    return String(format: "%02d:%02d", minutes, seconds)
}