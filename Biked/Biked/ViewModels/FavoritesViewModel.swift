import Foundation
import SwiftUI
import Combine

@Observable
class FavoritesViewModel {
    var favoriteBikeIDs: Set<String> = [] {
        didSet {
            saveFavorites()
            Task { await loadFavoriteBikes() }
        }
    }
    
    var favoriteBikes: [Bike] = []
    private let saveKey = "FavoriteBikeIDs"
    private let apiService: BikeAPIService
    
    init(apiService: BikeAPIService = .shared) {
        self.apiService = apiService
        loadFavorites()
        Task { await loadFavoriteBikes() }
    }
    
    func toggleFavorite(bikeId: String) {
        if favoriteBikeIDs.contains(bikeId) {
            favoriteBikeIDs.remove(bikeId)
        } else {
            favoriteBikeIDs.insert(bikeId)
        }
    }
    
    func removeFavorite(at offsets: IndexSet) {
        let idsToRemove = offsets.map { favoriteBikes[$0].id }
        for id in idsToRemove {
            favoriteBikeIDs.remove(id)
        }
    }
    
    func isFavorite(bikeId: String) -> Bool {
        favoriteBikeIDs.contains(bikeId)
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteBikeIDs) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
    
    func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteBikeIDs = decoded
        }
    }
    
    func loadFavoriteBikes() async {
        do {
            let allBikes = try await apiService.fetchBikes()
            favoriteBikes = allBikes.filter { favoriteBikeIDs.contains($0.id) }
        } catch {
            print("Error loading favorite bikes: \(error)")
        }
    }
}
