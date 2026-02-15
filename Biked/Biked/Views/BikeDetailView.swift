import SwiftUI

struct BikeDetailView: View {
    let bike: Bike
    let matchedGeometry: Geometry?
    
    @State private var selectedBuildId: String
    @State private var currentImageIndex = 0
    
    init(bike: Bike, matchedGeometry: Geometry? = nil) {
        self.bike = bike
        self.matchedGeometry = matchedGeometry
        // Default to first build
        _selectedBuildId = State(initialValue: bike.builds.first?.id ?? "")
    }
    
    var selectedBuild: BikeBuild? {
        bike.builds.first(where: { $0.id == selectedBuildId })
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // --- IMAGE CAROUSEL ---
                if let build = selectedBuild, !build.images.isEmpty {
                    TabView(selection: $currentImageIndex) {
                        ForEach(0..<build.images.count, id: \.self) { index in
                            AsyncImage(url: build.images[index]) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 250)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 250)
                        .overlay(Text("No Image Available"))
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    // --- HEADER ---
                    Text(bike.brand.uppercased())
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    Text(bike.model)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    
                    Text("\(bike.category) • \(String(bike.year))")
                        .font(.caption)
                        .padding(5)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(5)
                    
                    Text(bike.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    // --- BUILD SELECTION ---
                    if bike.builds.count > 1 {
                        Text("Montaje y Color")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(bike.builds) { build in
                                    Button(action: {
                                        selectedBuildId = build.id
                                        currentImageIndex = 0
                                    }) {
                                        VStack(alignment: .leading) {
                                            Text(build.name)
                                                .font(.caption)
                                                .bold()
                                            Text(build.color)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                            Text("€\(Int(build.priceEur))")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedBuildId == build.id ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                                        )
                                    }
                                    .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    
                    // --- SPECS & PRICE ---
                    if let build = selectedBuild {
                        HStack {
                            Text("Precio")
                            Spacer()
                            Text("€\(Int(build.priceEur))")
                                .font(.title3)
                                .bold()
                        }
                        .padding(.vertical, 5)
                        
                        GroupBox(label: Label("Especificaciones", systemImage: "gear")) {
                            VStack(alignment: .leading, spacing: 10) {
                                SpecRow(icon: "bicycle", title: "Grupo", value: build.specs.groupset)
                                SpecRow(icon: "circle.circle", title: "Ruedas", value: build.specs.wheelset)
                                SpecRow(icon: "bolt", title: "Potenciómetro", value: build.specs.powerMeter)
                            }
                            .padding(.top, 5)
                        }
                        
                        // --- INVENTORY ---
                        GroupBox(label: Label("Disponibilidad", systemImage: "shippingbox")) {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 10) {
                                ForEach(build.inventory.keys.sorted(), id: \.self) { size in
                                    let qty = build.inventory[size] ?? 0
                                    VStack {
                                        Text(size)
                                            .font(.caption)
                                            .bold()
                                        Text(qty > 0 ? "\(qty)" : "Agotado")
                                            .font(.caption2)
                                            .foregroundColor(qty > 0 ? .green : .red)
                                    }
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(matchedGeometry?.size == size ? Color.green : Color.clear, lineWidth: 2)
                                    )
                                }
                            }
                            .padding(.top, 5)
                        }
                    }
                    
                    Divider()
                    
                    // --- GEOMETRY ---
                    Text("Geometría")
                        .font(.title2)
                        .bold()
                    
                    GeometryViewUpdated(bike: bike, matchedGeometry: matchedGeometry)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Helper View for Specs
struct SpecRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 25)
                .foregroundColor(.blue)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
        }
    }
}

// Updated Geometry View to handle new model
struct GeometryViewUpdated: View {
    let bike: Bike
    let matchedGeometry: Geometry?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            VStack(spacing: 0) {
                // Header Row
                HStack(spacing: 0) {
                    HeaderCell(text: "Size")
                    HeaderCell(text: "Stack")
                    HeaderCell(text: "Reach")
                    HeaderCell(text: "Top Tube")
                    HeaderCell(text: "Seat Tube")
                }
                .background(Color.gray.opacity(0.2))
                
                // Data Rows
                ForEach(bike.geometry, id: \.id) { geo in
                    let isMatch = geo.id == matchedGeometry?.id
                    HStack(spacing: 0) {
                        DataCell(text: geo.size, isHighlight: isMatch)
                        DataCell(text: "\(Int(geo.stack))", isHighlight: isMatch)
                        DataCell(text: "\(Int(geo.reach))", isHighlight: isMatch)
                        DataCell(text: "\(Int(geo.topTubeMm ?? 0))", isHighlight: isMatch)
                        DataCell(text: "\(Int(geo.seatTubeMm ?? 0))", isHighlight: isMatch)
                    }
                    .background(isMatch ? Color.green.opacity(0.2) : Color.clear)
                }
            }
            .cornerRadius(10)
            .padding(.bottom, 20)
        }
    }
}

struct HeaderCell: View {
    let text: String
    var body: some View {
        Text(text)
            .bold()
            .frame(width: 80, height: 40)
            .border(Color.gray.opacity(0.1))
    }
}

struct DataCell: View {
    let text: String
    let isHighlight: Bool
    var body: some View {
        Text(text)
            .fontWeight(isHighlight ? .bold : .regular)
            .frame(width: 80, height: 40)
            .border(Color.gray.opacity(0.1))
            .foregroundColor(isHighlight ? .green : .primary)
    }
}
