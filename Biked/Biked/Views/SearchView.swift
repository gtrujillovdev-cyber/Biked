import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @Environment(FavoritesViewModel.self) private var favoritesViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Encuentra tu talla ideal")
                            .font(.system(size: 28, weight: .bold, design: .default))
                            .foregroundStyle(.primary)
                        
                        Text("Introduce tu Stack y Reach para obtener recomendaciones precisas.")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Input Form
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            FloatingInput(title: "Stack (mm)", text: $viewModel.userStack)
                            FloatingInput(title: "Reach (mm)", text: $viewModel.userReach)
                        }
                        
                        Button(action: {
                            Task {
                                await viewModel.search()
                            }
                        }) {
                            Text(viewModel.isSearching ? "Buscando..." : "Buscar Bicis")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .disabled(viewModel.isSearching)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Results
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.subheadline)
                            .padding()
                    }
                    
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.searchResults) { result in
                            NavigationLink(destination: BikeDetailView(result: result)) {
                                matchCard(for: result)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Buscador")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private func matchCard(for result: MatchingResult) -> some View {
        VStack(spacing: 0) {
            // Image
            AsyncImage(url: result.bike.imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 180)
                        .clipped()
                case .failure:
                    ZStack {
                        Color.gray.opacity(0.1)
                        Image(systemName: "bicycle")
                            .font(.system(size: 40))
                            .foregroundStyle(.gray)
                        Text("No Image")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .padding(.top, 60)
                    }
                    .frame(height: 180)
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 180)
                        .overlay(ProgressView())
                @unknown default:
                    EmptyView()
                }
            }
            .background(Color.white)
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(result.bike.brand.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        Text(result.bike.modelName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Text(result.preciseMatch ? "MATCH EXACTO" : "APROXIMADO")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(result.preciseMatch ? Color.green : Color.orange)
                        .cornerRadius(4)
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Tu Talla")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(result.matchedGeometry.sizeLabel)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Precio")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "€%.0f", result.bike.price))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding(16)
            .background(Color(UIColor.systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// Simple floating label input component
struct FloatingInput: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("0", text: $text)
                .keyboardType(.decimalPad)
                .font(.system(size: 20, weight: .medium))
                .padding(12)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}
