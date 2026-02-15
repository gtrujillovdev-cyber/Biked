import Foundation

struct BikeSpecs: Codable, Hashable {
    let groupset: String
    let wheelset: String
    let powerMeter: String
    
    enum CodingKeys: String, CodingKey {
        case groupset, wheelset
        case powerMeter = "power_meter"
    }
}

struct BikeBuild: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let color: String
    let priceEur: Double
    let images: [URL]
    let specs: BikeSpecs
    let inventory: [String: Int] // Map size -> quantity
    
    enum CodingKeys: String, CodingKey {
        case id, name, color, images, specs, inventory
        case priceEur = "price_eur"
    }
    
    var formattedPrice: String {
        return "€\(Int(priceEur))"
    }
}

struct Bike: Identifiable, Codable, Hashable {
    let id: String
    let brand: String
    let model: String
    let year: Int
    let category: String
    let description: String
    let officialUrl: String?
    let geometry: [Geometry]
    let builds: [BikeBuild]
    
    // Computed helper to get a representative image (first build, first image)
    var mainImage: URL? {
        guard let url = builds.first?.images.first else { return nil }
        return resolveImageURL(url)
    }
    
    func resolveImageURL(_ url: URL) -> URL? {
        if url.scheme?.hasPrefix("http") == true {
            return url
        }
        
        // Local file logic (Check 'BikeImages' folder in Bundle)
        let filename = url.lastPathComponent
        return Bundle.main.url(forResource: filename, withExtension: nil)
            ?? Bundle.main.url(forResource: filename, withExtension: nil, subdirectory: "BikeImages")
    }
    
    enum CodingKeys: String, CodingKey {
        case id, brand, model, year, category, description, geometry, builds
        case officialUrl = "official_url"
    }
    
    var priceRange: String {
        let prices = builds.map { $0.priceEur }
        guard let minPrice = prices.min(), let maxPrice = prices.max() else { return "N/A" }
        
        if minPrice != maxPrice {
            return "€\(Int(minPrice)) - €\(Int(maxPrice))"
        } else {
            return "€\(Int(minPrice))"
        }
    }
}
