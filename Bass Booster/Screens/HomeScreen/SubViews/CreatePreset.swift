import SwiftUI

struct CreatePresetView: View {
    @Binding var isPresented: Bool
    @State private var presetName: String = ""
    var onSave: (String) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Name a preset")
                    .font(.quicksand(type: .bold700, size: 20))
                    .foregroundColor(.white)
                
                CustomTextField(input: $presetName, text: "Name of preset")
                
                
                HStack(spacing: 20) {
                    Button(action: {
                        onCancel()
                    }) {
                        Text("Cancel")
                            .font(.sfProDisplay(type: .medium500, size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.tabBarSelected, lineWidth: 1)
                            )
                    }
                    
                    // Save Button
                    Button(action: {
                        if !presetName.isEmpty {
                            onSave(presetName)
                        }
                    }) {
                        Text("Save")
                            .font(.sfProDisplay(type: .medium500, size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.tabBarSelected)
                            .cornerRadius(25)
                    }
                    .disabled(presetName.isEmpty)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.customBlack)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal, 35)
        }
    }
}

struct CreatePresetView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePresetView(isPresented: .constant(true), onSave: { _ in }, onCancel: {})
    }
}
