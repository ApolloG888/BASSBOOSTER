import Foundation
import SwiftUI

enum SearchState {
    case awaiting
    case searching
}

struct SearchBarView: View {
    @State private var searchText = ""
    @State private var state: SearchState = .awaiting
    
    var action: (()-> Void)?
    
    var body: some View {
        ZStack(alignment: .leading) {
            if searchText.isEmpty {
                Text("Start type")
                    .foregroundColor(Color.white.opacity(0.5))
                    .font(.sfProText(type: .regular400, size: 14))
                    .padding(16)
            }
            
            TextField("", text: $searchText)
                .font(.sfProText(type: .regular400, size: 14))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.white.opacity(0.07))
                .accentColor(.yellow)
                .cornerRadius(8)
                .foregroundColor(.white)
                
            
            HStack {
                Spacer()
                Button(action: {
                    action?()
                }) {
                    Image(state == .awaiting ? .magnifer : .discardSearch)
                }
                .padding(.trailing)
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        SearchBarView()
            .padding()
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
