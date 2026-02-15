import Foundation

struct Bike: Identifiable, Codable {
    let id: String // Use String ID for easier JSON mapping, or UUID if preferred
    let brand: String
    let modelName: String
    let price: Double
    let imageUrl: URL?
    let geometries: [Geometry]
    
    // Computed property to get a specific size geometry if needed
    func geometry(forSize size: String) -> Geometry? {
        geometries.first { $0.sizeLabel == size }
    }
}
