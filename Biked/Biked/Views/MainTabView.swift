import SwiftUI

struct MainTabView: View {
    @State private var favoritesViewModel = FavoritesViewModel()
    
    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label("Buscar", systemImage: "magnifyingglass")
                }
            
            ExploreView()
                .tabItem {
                    Label("Explorar", systemImage: "bicycle")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Favoritos", systemImage: "heart")
                }
        }
        .environment(favoritesViewModel)
        .tint(.blue) // Apple Health style blue
    }
}
