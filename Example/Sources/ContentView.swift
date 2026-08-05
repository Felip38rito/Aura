import AuraDS
import AuraKernel
import SwiftUI

// MARK: - Content View
//
// Acts as the main hub for the didactic example, demonstrating the three 
// pillars of the Aura framework: Kernel, Design System, and SDUI.
struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                KernelsView()
            }
            .tabItem {
                Label("Kernels", systemImage: "puzzlepiece")
            }
            
            NavigationStack {
                DesignSystemView()
            }
            .tabItem {
                Label("Design System", systemImage: "paintpalette")
            }
            
            NavigationStack {
                SDUIView()
            }
            .tabItem {
                Label("SDUI", systemImage: "server.rack")
            }
        }
    }
}
