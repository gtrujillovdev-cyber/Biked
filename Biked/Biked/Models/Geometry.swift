import Foundation

struct Geometry: Identifiable, Codable, Hashable {
    var id: String { sizeLabel }
    let sizeLabel: String // e.g., "S", "54"
    let stack: Double // mm
    let reach: Double // mm
    let topTubeLength: Double? // mm
    let seatTubeAngle: Double? // degrees
    let headTubeAngle: Double? // degrees
    
    // Helper for matching score
    func distance(to targetStack: Double, targetReach: Double) -> Double {
        let stackDiff = stack - targetStack
        let reachDiff = reach - targetReach
        return sqrt(pow(stackDiff, 2) + pow(reachDiff, 2))
    }
}
