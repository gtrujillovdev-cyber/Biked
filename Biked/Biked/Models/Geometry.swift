import Foundation

struct Geometry: Codable, Hashable, Identifiable {
    var id: String { size }
    let size: String
    let stackMm: Double
    let reachMm: Double
    let topTubeMm: Double?
    let seatTubeMm: Double?
    
    // Computed properties for compatibility/logic
    var stack: Double { stackMm }
    var reach: Double { reachMm }
    
    enum CodingKeys: String, CodingKey {
        case size
        case stackMm = "stack_mm"
        case reachMm = "reach_mm"
        case topTubeMm = "top_tube_mm"
        case seatTubeMm = "seat_tube_mm"
    }
    
    // Helper helper for matching score
    func distance(to targetStack: Double, targetReach: Double) -> Double {
        let stackDiff = stack - targetStack
        let reachDiff = reach - targetReach
        return sqrt(pow(stackDiff, 2) + pow(reachDiff, 2)) // Simple Euclidean distance
    }
}
