import Foundation
import SwiftUI

@Observable
class FavoritesViewModel {
    var favoriteBikeIDs: Set<String> = [] {
        didSet {
            saveFavorites()
        }
    }
    
    private let saveKey = "FavoriteBikeIDs"
    
    init() {
        loadFavorites()
    }
    
    func toggleFavorite(bikeId: String) {
        if favoriteBikeIDs.contains(bikeId) {
            favoriteBikeIDs.remove(bikeId)
        } else {
            favoriteBikeIDs.insert(bikeId)
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
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteBikeIDs = decoded
        }
    }
}
