import Foundation

class BikeAPIService {
    static let shared = BikeAPIService()
    
    // URL for the "Indie Backend"
    // Assuming the repo root corresponds to the folder with .git
    private let databaseURL = URL(string: "https://raw.githubusercontent.com/gtrujillovdev-cyber/Biked/main/Biked/Data/bikes.json")!
    
    // For local testing before push, we can try to load from Bundle if the file is added,
    // or just return the static data if the network fails.
    
    func fetchBikes() async throws -> [Bike] {
        // 1. Try to fetch from the "Real" API (GitHub Raw)
        do {
            let (data, response) = try await URLSession.shared.data(from: databaseURL)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            let bikes = try JSONDecoder().decode([Bike].self, from: data)
            return bikes
            
        } catch {
            print("Error fetching from GitHub: \(error). Falling back to local data.")
            // 2. Fallback: Return local mock data (which matches the JSON structure)
            // In a real app, you might want to show an alert or load from local cache
            return getLocalFallbackData()
        }
    }
    
    private func getLocalFallbackData() -> [Bike] {
        return [
            Bike(
                id: "canyon-aeroad-cfr",
                brand: "Canyon",
                modelName: "Aeroad CFR",
                price: 8999.0,
                imageUrl: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Canyon_Aeroad_CF_SLX_-_Stage_8_-_Tour_of_Britain_2016.jpg/640px-Canyon_Aeroad_CF_SLX_-_Stage_8_-_Tour_of_Britain_2016.jpg"),
                geometries: [
                    Geometry(sizeLabel: "2XS", stack: 493, reach: 365, topTubeLength: 508, seatTubeAngle: 73.5, headTubeAngle: 70.0),
                    Geometry(sizeLabel: "XS", stack: 512, reach: 376, topTubeLength: 526, seatTubeAngle: 73.5, headTubeAngle: 71.0),
                    Geometry(sizeLabel: "S", stack: 533, reach: 385, topTubeLength: 543, seatTubeAngle: 73.5, headTubeAngle: 72.0),
                    Geometry(sizeLabel: "M", stack: 555, reach: 395, topTubeLength: 560, seatTubeAngle: 73.5, headTubeAngle: 73.0),
                    Geometry(sizeLabel: "L", stack: 576, reach: 405, topTubeLength: 577, seatTubeAngle: 73.5, headTubeAngle: 73.25),
                    Geometry(sizeLabel: "XL", stack: 597, reach: 415, topTubeLength: 596, seatTubeAngle: 73.5, headTubeAngle: 73.5),
                    Geometry(sizeLabel: "2XL", stack: 618, reach: 425, topTubeLength: 616, seatTubeAngle: 73.5, headTubeAngle: 73.75)
                ]
            ),
            Bike(
                id: "orbea-orca-aero",
                brand: "Orbea",
                modelName: "Orca Aero",
                price: 5999.0,
                imageUrl: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Road_bike_Orbea_Orca_Aero_2020.jpg/640px-Road_bike_Orbea_Orca_Aero_2020.jpg"),
                geometries: [
                    Geometry(sizeLabel: "47", stack: 506, reach: 368, topTubeLength: 510, seatTubeAngle: 74.5, headTubeAngle: 71.0),
                    Geometry(sizeLabel: "49", stack: 519, reach: 374, topTubeLength: 523, seatTubeAngle: 74.0, headTubeAngle: 71.5),
                    Geometry(sizeLabel: "51", stack: 535, reach: 380, topTubeLength: 536, seatTubeAngle: 73.7, headTubeAngle: 72.2),
                    Geometry(sizeLabel: "53", stack: 553, reach: 386, topTubeLength: 549, seatTubeAngle: 73.5, headTubeAngle: 72.8),
                    Geometry(sizeLabel: "55", stack: 572, reach: 393, topTubeLength: 563, seatTubeAngle: 73.5, headTubeAngle: 73.0),
                    Geometry(sizeLabel: "57", stack: 591, reach: 400, topTubeLength: 576, seatTubeAngle: 73.5, headTubeAngle: 73.2),
                    Geometry(sizeLabel: "60", stack: 615, reach: 408, topTubeLength: 590, seatTubeAngle: 73.5, headTubeAngle: 73.5)
                ]
            ),
            Bike(
                id: "specialized-tarmac-sl8",
                brand: "Specialized",
                modelName: "Tarmac SL8",
                price: 12500.0,
                imageUrl: URL(string: "https://media.specialized.com/bikes/road/5758_TarmacSL8_ArticleTile_580x618_02.jpg"),
                geometries: [
                    Geometry(sizeLabel: "44", stack: 491, reach: 365, topTubeLength: 496, seatTubeAngle: 75.5, headTubeAngle: 70.5),
                    Geometry(sizeLabel: "49", stack: 504, reach: 375, topTubeLength: 508, seatTubeAngle: 75.5, headTubeAngle: 71.75),
                    Geometry(sizeLabel: "52", stack: 517, reach: 380, topTubeLength: 531, seatTubeAngle: 74.0, headTubeAngle: 72.5),
                    Geometry(sizeLabel: "54", stack: 534, reach: 384, topTubeLength: 541, seatTubeAngle: 74.0, headTubeAngle: 73.0),
                    Geometry(sizeLabel: "56", stack: 555, reach: 395, topTubeLength: 562, seatTubeAngle: 73.5, headTubeAngle: 73.5),
                    Geometry(sizeLabel: "58", stack: 581, reach: 402, topTubeLength: 577, seatTubeAngle: 73.5, headTubeAngle: 73.5),
                    Geometry(sizeLabel: "61", stack: 602, reach: 408, topTubeLength: 595, seatTubeAngle: 73.0, headTubeAngle: 74.0)
                ]
            )
        ]
    }
}
