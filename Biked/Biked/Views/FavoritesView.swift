import SwiftUI

struct FavoritesView: View {
    @Environment(FavoritesViewModel.self) private var favoritesViewModel
    @State private var favoriteBikes: [Bike] = []
    
    var body: some View {
        NavigationStack {
            Group {
                if favoriteBikes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 50))
                            .foregroundStyle(.gray)
                        Text("No tienes favoritos aún")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List {
                        ForEach(favoriteBikes) { bike in
                            NavigationLink(destination: BikeDetailView(result: createMockMatch(for: bike))) {
                                HStack(spacing: 12) {
                                    AsyncImage(url: bike.imageUrl) { phase in
                                        if let image = phase.image {
                                            image.resizable().aspectRatio(contentMode: .fit)
                                        } else if phase.error != nil {
                                            ZStack {
                                                Color.gray.opacity(0.1)
                                                Image(systemName: "bicycle")
                                                    .foregroundStyle(.gray)
                                            }
                                        } else {
                                            Color.gray.opacity(0.1)
                                        }
                                    }
                                    .frame(width: 80, height: 60)
                                    
                                    VStack(alignment: .leading) {
                                        Text(bike.modelName)
                                            .font(.headline)
                                        Text(bike.brand)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favoritos")
            .onAppear {
                loadFavorites()
            }
            .onChange(of: favoritesViewModel.favoriteBikeIDs) { _, _ in
                loadFavorites()
            }
        }
    }
    
    private func loadFavorites() {
        Task {
            do {
                let allBikes = try await BikeAPIService.shared.fetchBikes()
                favoriteBikes = allBikes.filter { favoritesViewModel.isFavorite(bikeId: $0.id) }
            } catch {
                print("Error loading favorites: \(error)")
            }
        }
    }
    
    // Helper to create a dummy match result for the detail view since we don't have user input here
    // In a real app, we might persist the user's last input or show the detail view without match data
    private func createMockMatch(for bike: Bike) -> MatchingResult {
        // Just pick the middle size for display purposes
        let middleGeo = bike.geometries[bike.geometries.count / 2]
        return MatchingResult(
            bike: bike,
            matchedGeometry: middleGeo,
            userStack: middleGeo.stack, // Mock exact match
            userReach: middleGeo.reach,
            distance: 0
        )
    }
}
