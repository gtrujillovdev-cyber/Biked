import SwiftUI
import Charts

struct BikeDetailView: View {
    let result: MatchingResult
    @Environment(FavoritesViewModel.self) private var favoritesViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Image
                AsyncImage(url: result.bike.imageUrl) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else if phase.error != nil {
                        ZStack {
                            Color.gray.opacity(0.1)
                            Image(systemName: "bicycle")
                                .font(.system(size: 60))
                                .foregroundStyle(.gray)
                            Text("No Image Available")
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .padding(.top, 80)
                        }
                        .frame(height: 250)
                    } else {
                        Color.gray.opacity(0.1)
                            .frame(height: 250)
                            .overlay(ProgressView())
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                
                VStack(alignment: .leading, spacing: 24) {
                    // Header Info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(result.bike.brand)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button(action: {
                                favoritesViewModel.toggleFavorite(bikeId: result.bike.id)
                            }) {
                                Image(systemName: favoritesViewModel.isFavorite(bikeId: result.bike.id) ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundStyle(.red)
                            }
                        }
                        
                        Text(result.bike.modelName)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Text(String(format: "€%.0f", result.bike.price))
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                    
                    Divider()
                    
                    // Match Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tu Talla Ideal: \(result.matchedGeometry.sizeLabel)")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("Esta talla es la que mejor se adapta a tu Stack/Reach con una desviación de \(String(format: "%.1f", result.distance))mm.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                    // Geometry Comparison Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Comparativa de Geometría")
                            .font(.headline)
                        
                        Chart {
                            // User Point
                            PointMark(
                                x: .value("Reach", result.userReach),
                                y: .value("Stack", result.userStack)
                            )
                            .symbol {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 12, height: 12)
                            }
                            .annotation(position: .top) {
                                Text("Tú")
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(.blue)
                            }
                            
                            // Bike Geometries
                            ForEach(result.bike.geometries) { geo in
                                PointMark(
                                    x: .value("Reach", geo.reach),
                                    y: .value("Stack", geo.stack)
                                )
                                .foregroundStyle(geo.id == result.matchedGeometry.id ? Color.green : Color.gray.opacity(0.3))
                                .symbolSize(geo.id == result.matchedGeometry.id ? 100 : 50)
                                .annotation(position: .top) {
                                    if geo.id == result.matchedGeometry.id {
                                        Text(geo.sizeLabel)
                                            .font(.caption)
                                            .bold()
                                            .foregroundStyle(.green)
                                    }
                                }
                            }
                        }
                        .chartXAxisLabel("Reach (mm)")
                        .chartYAxisLabel("Stack (mm)")
                        .frame(height: 250)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        
                        Text("El punto verde muestra la talla recomendada. Los puntos grises son otras tallas de este modelo.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                    // Specs Table
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detalles Geometría (\(result.matchedGeometry.sizeLabel))")
                            .font(.headline)
                        
                        GeometryRow(label: "Stack", value: String(format: "%.0f mm", result.matchedGeometry.stack))
                        GeometryRow(label: "Reach", value: String(format: "%.0f mm", result.matchedGeometry.reach))
                        if let tt = result.matchedGeometry.topTubeLength {
                            GeometryRow(label: "Tubo Superior", value: String(format: "%.0f mm", tt))
                        }
                        if let sta = result.matchedGeometry.seatTubeAngle {
                            GeometryRow(label: "Ángulo Sillín", value: String(format: "%.1f°", sta))
                        }
                        if let hta = result.matchedGeometry.headTubeAngle {
                            GeometryRow(label: "Ángulo Dirección", value: String(format: "%.1f°", hta))
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GeometryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}
