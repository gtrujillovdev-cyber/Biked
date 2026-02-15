import SwiftUI

struct ExploreView: View {
    @State private var bikes: [Bike] = []
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(bikes) { bike in
                    NavigationLink(destination: BikeDetailView(bike: bike)) {
                        HStack(spacing: 12) {
                            AsyncImage(url: bike.mainImage) { image in
                                image.resizable().aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Color.gray.opacity(0.1)
                            }
                            .frame(width: 80, height: 60)
                            
                            VStack(alignment: .leading) {
                                Text(bike.model)
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
            .navigationTitle("Explorar")
            .task {
                do {
                    // In a real app we might want a separate ViewModel for this or basic filtering
                    bikes = try await BikeAPIService.shared.fetchBikes()
                } catch {
                    print("Failed to load bikes: \(error)")
                }
            }
        }
    }
}
