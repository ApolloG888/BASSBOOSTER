import Foundation
import SwiftUI

struct MainTabAssembly {
    
    @MainActor
    func build() -> some View {
        return MainTabView()
    }
}
