import Foundation

class BikeAPIService {
    static let shared = BikeAPIService()
    
    // URL for the "Indie Backend"
    // Validated Path: RepoRoot -> Biked -> Biked -> Data -> bikes.json
    private let databaseURL = URL(string: "https://raw.githubusercontent.com/gtrujillovdev-cyber/Biked/main/Biked/Biked/Data/bikes.json")!
    
    // For local testing before push, we can try to load from Bundle if the file is added,
    // or just return the static data if the network fails.
    
    func fetchBikes() async throws -> [Bike] {
        // 1. Try to fetch from the "Real" API (GitHub Raw)
        do {
            print("Attempting to fetch from: \(databaseURL.absoluteString)")
            let (data, response) = try await URLSession.shared.data(from: databaseURL)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Not an HTTP response")
                throw URLError(.badServerResponse)
            }
            
            print("Status Code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("Error: Status code \(httpResponse.statusCode)")
                throw URLError(.badServerResponse)
            }
            
            let bikes = try JSONDecoder().decode([Bike].self, from: data)
            print("Successfully fetched \(bikes.count) bikes from GitHub!")
            return bikes
            
        } catch {
            print("--------------------------------------------------")
            print("CRITICAL ERROR FETCHING FROM GITHUB:")
            print(error)
            print("--------------------------------------------------")
            print("Falling back to local data.")
            // 2. Fallback: Return local mock data
            return getLocalFallbackData()
        }
    }
    
    private func getLocalFallbackData() -> [Bike] {
        return [] // Local fallback removed to avoid maintenance of hardcoded data.
    }
}
