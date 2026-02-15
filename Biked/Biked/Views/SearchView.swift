import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @State private var isFiltersExpanded = true
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Encuentra tu Bici Ideal")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                if isFiltersExpanded {
                    // Mode Selection
                    Picker("Modo de Búsqueda", selection: $viewModel.searchMode) {
                        Text("Por Medidas").tag(SearchViewModel.SearchMode.biometric)
                        Text("Por Geometría").tag(SearchViewModel.SearchMode.geometric)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    VStack(spacing: 20) {
                        if viewModel.searchMode == .biometric {
                            // Biometric Inputs
                            TextField("Altura del Ciclista (cm)", text: $viewModel.userHeight)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                            
                            TextField("Entrepierna (cm)", text: $viewModel.userInseam)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                            
                            if let stack = viewModel.targetStack, let reach = viewModel.targetReach {
                                VStack(spacing: 5) {
                                    Text("Geometría Estimada:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("Stack: \(Int(stack))mm | Reach: \(Int(reach))mm")
                                        .font(.system(.subheadline, design: .monospaced))
                                        .bold()
                                }
                                .padding(10)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                        } else {
                            // Geometric Inputs
                            TextField("Stack (mm)", text: $viewModel.userStack)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                            
                            TextField("Reach (mm)", text: $viewModel.userReach)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        
                        Button(action: {
                            Task {
                                withAnimation {
                                    isFiltersExpanded = false
                                }
                                await viewModel.search()
                            }
                        }) {
                            if viewModel.isSearching {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Buscar")
                                    .bold()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                } else {
                    // Collapsed View (Summary)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Buscando por: \(viewModel.searchMode == .biometric ? "Medidas" : "Geometría")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if viewModel.searchMode == .biometric {
                                Text("H: \(viewModel.userHeight)cm | I: \(viewModel.userInseam)cm")
                                    .font(.headline)
                            } else {
                                Text("S: \(viewModel.userStack)mm | R: \(viewModel.userReach)mm")
                                    .font(.headline)
                            }
                        }
                        Spacer()
                        Button("Modificar") {
                            withAnimation {
                                isFiltersExpanded = true
                            }
                        }
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                List(viewModel.searchResults) { result in
                    NavigationLink(destination: BikeDetailView(bike: result.bike, matchedGeometry: result.matchedGeometry)) {
                        HStack {
                            AsyncImage(url: result.bike.mainImage) { image in
                                image.resizable().aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 80, height: 60)
                            .cornerRadius(8)
                            
                            VStack(alignment: .leading) {
                                Text(result.bike.brand)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(result.bikeName) // Uses bike.model
                                    .font(.headline)
                                Text("Talla: \(result.matchedSize)")
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(String(format: "Diff: %.0fmm", result.distance))
                                    .font(.caption)
                                    .foregroundColor(result.distance < 10 ? .green : .orange)
                                Text(result.bike.priceRange)
                                        .font(.caption)
                                        .bold()
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .padding()
        }
    }
}

#Preview {
    SearchView()
}
