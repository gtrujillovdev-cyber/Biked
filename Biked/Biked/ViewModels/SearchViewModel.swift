import Foundation
import SwiftUI
import Combine

@Observable
class SearchViewModel {
    enum SearchMode {
        case biometric
        case geometric
    }
    
    var searchMode: SearchMode = .biometric
    
    // Geometric Inputs
    var userStack: String = ""
    var userReach: String = ""
    var tolerance: Double = 10.0
    
    // Biometric Inputs
    var userHeight: String = ""
    var userInseam: String = ""
    
    var searchResults: [MatchingResult] = []
    var isSearching: Bool = false
    var errorMessage: String?
    
    // Computed property to show what we are searching for
    var targetStack: Double? {
        if searchMode == .geometric {
            return Double(userStack)
        } else {
            return estimateTargetGeometry().stack
        }
    }
    
    var targetReach: Double? {
        if searchMode == .geometric {
            return Double(userReach)
        } else {
            return estimateTargetGeometry().reach
        }
    }
    
    private let apiService: BikeAPIService
    
    init(apiService: BikeAPIService = .shared) {
        self.apiService = apiService
    }
    
    func search() async {
        let stack: Double
        let reach: Double
        
        // Determine target Stack/Reach based on mode
        switch searchMode {
        case .geometric:
            guard let s = Double(userStack), let r = Double(userReach) else {
                errorMessage = "Introduzca valores válidos para Stack y Reach."
                return
            }
            stack = s
            reach = r
            
        case .biometric:
            guard let h = Double(userHeight), let i = Double(userInseam) else {
                errorMessage = "Introduzca su altura y entrepierna."
                return
            }
            let targets = estimateTargetGeometry(height: h, inseam: i)
            guard let s = targets.stack, let r = targets.reach else {
                errorMessage = "No se pudo estimar la geometría."
                return
            }
            stack = s
            reach = r
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
    
    // Simple Estimation Logic
    // Based on standard endurance road bike regression
    // Stack ~= 0.69 * Inseam
    // Reach ~= Height * 0.38 + Adjustment (approx)
    // Refinement:
    // Reach is often related to Trunk + Arm length, but Height is a decent proxy.
    // Ratio Reach/Height ~ 0.22 - 0.24 for Endurance geometry
    private func estimateTargetGeometry(height: Double? = nil, inseam: Double? = nil) -> (stack: Double?, reach: Double?) {
        let h = height ?? Double(userHeight)
        let i = inseam ?? Double(userInseam)
        
        guard let validHeight = h, let validInseam = i else {
            return (nil, nil)
        }
        
        // Estimation Formulas (Endurance Road Bike / Gran Fondo)
        // Stack: Highly correlated with leg length (Inseam)
        // Formula: Inseam * 0.69 (Common fit shorthand)
        // Formula: Inseam * 0.69 (Common fit shorthand) -> Result is in CM, convert to MM
        let estimatedStack = validInseam * 0.69 * 10
        
        // Reach: Correlated with overall height
        // Formula: Height * 0.225 (Approximate for comfortable position) -> Result is in CM, convert to MM
        let estimatedReach = validHeight * 0.225 * 10
        
        return (estimatedStack, estimatedReach)
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
