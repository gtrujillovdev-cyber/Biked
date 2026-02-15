import SwiftUI
import Combine

struct FavoritesView: View {
    @State private var viewModel = FavoritesViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favoriteBikes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No tienes favoritos aún")
                            .font(.title2)
                            .bold()
                        Text("Tus bicicletas guardadas aparecerán aquí")
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(viewModel.favoriteBikes) { bike in
                            NavigationLink(destination: BikeDetailView(bike: bike)) {
                                HStack {
                                    AsyncImage(url: bike.mainImage) { image in
                                        image.resizable().aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        Color.gray.opacity(0.3)
                                    }
                                    .frame(width: 80, height: 60)
                                    .cornerRadius(8)
                                    
                                    VStack(alignment: .leading) {
                                        Text(bike.model)
                                            .font(.headline)
                                        Text(bike.brand)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(bike.priceRange)
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .onDelete(perform: viewModel.removeFavorite)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favoritos")
            .onAppear {
                viewModel.loadFavorites()
            }
        }
    }
}

#Preview {
    FavoritesView()
}
