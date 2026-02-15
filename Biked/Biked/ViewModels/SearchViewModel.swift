import Foundation
import SwiftUI
import Combine

@Observable
class SearchViewModel {
    var userStack: String = ""
    var userReach: String = ""
    var tolerance: Double = 10.0
    
    var searchResults: [MatchingResult] = []
    var isSearching: Bool = false
    var errorMessage: String?
    
    private let apiService: BikeAPIService
    
    init(apiService: BikeAPIService = .shared) {
        self.apiService = apiService
    }
    
    func search() async {
        guard let stack = Double(userStack), let reach = Double(userReach) else {
            errorMessage = "Introduzca valores válidos para Stack y Reach."
            return
        }
        
        isSearching = true
        errorMessage = nil
        searchResults = []
        
        do {
            let bikes = try await apiService.fetchBikes()
            searchResults = findMatches(for: bikes, userStack: stack, userReach: reach, tolerance: tolerance)
        } catch {
            errorMessage = "Error al cargar bicicletas: \(error.localizedDescription)"
        }
        
        isSearching = false
    }
    
    private func findMatches(for bikes: [Bike], userStack: Double, userReach: Double, tolerance: Double) -> [MatchingResult] {
        var matches: [MatchingResult] = []
        
        for bike in bikes {
            // Find the best geometry for this bike
            // bike.geometry is the new array name
            let bestMatch = bike.geometry.min(by: { 
                $0.distance(to: userStack, targetReach: userReach) < $1.distance(to: userStack, targetReach: userReach)
            })
            
            if let best = bestMatch {
                let distance = best.distance(to: userStack, targetReach: userReach)
                
                // Only include reasonable matches (e.g. within tolerance + 20mm buffer to be safe, or just always include best and let user decide)
                // For now, let's include all valid matches found
                let match = MatchingResult(
                    bike: bike,
                    matchedGeometry: best,
                    userStack: userStack,
                    userReach: userReach,
                    distance: distance
                )
                matches.append(match)
            }
        }
        
        return matches.sorted(by: { $0.distance < $1.distance })
    }
}
