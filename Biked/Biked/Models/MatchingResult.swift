import Foundation

struct MatchingResult: Identifiable {
    let id = UUID()
    let bike: Bike
    let matchedGeometry: Geometry
    let userStack: Double
    let userReach: Double
    let distance: Double
    
    var preciseMatch: Bool {
        return distance <= 10.0 // Hardcoded tolerance for "Green" match
    }
}
