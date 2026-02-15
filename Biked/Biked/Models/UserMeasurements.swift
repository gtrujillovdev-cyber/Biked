import Foundation

struct UserMeasurements: Codable {
    var stack: Double
    var reach: Double
    var tolerance: Double = 10.0 // Default tolerance in mm
}
