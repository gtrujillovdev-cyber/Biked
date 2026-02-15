import Foundation

struct MatchingResult: Identifiable, Hashable {
    let id = UUID()
    let bike: Bike
    let matchedGeometry: Geometry
    let userStack: Double
    let userReach: Double
    let distance: Double
    
    var stackDifference: Double {
        matchedGeometry.stack - userStack
    }
    
    var reachDifference: Double {
        matchedGeometry.reach - userReach
    }
    
    // Computed properties for easy access
    var bikeName: String { bike.model }
    var brand: String { bike.brand }
    var matchedSize: String { matchedGeometry.size }
    
    // Score (lower is better, 0 is perfect match)
    var matchScore: Double {
        abs(stackDifference) + abs(reachDifference)
    }
}
