import SwiftUI

struct ProductView: View {
    var productDuration: String
    var weekPrice: String
    var fullPrice: String
    var selected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: CornerRadius.l) {
            HStack {
                Text(productDuration)
                    .font(.sfProText(type: .semiBold600, size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Popular")
                    .font(.sfProText(type: .medium500, size: 10))
                    .padding(Space.xs)
                    .background(.subProductTagColor)
                    .cornerRadius(CornerRadius.xl3 * 2)
                    .foregroundColor(.white)
                
            }
            
            VStack(alignment: .leading, spacing: Space.xs3) {
                Text(weekPrice)
                    .font(.sfProText(type: .medium500, size: 16))
                    .foregroundColor(.subProductPriceColor)
                Text(fullPrice)
                    .font(.sfProText(type: .regular400, size: 12))
                    .foregroundColor(.subProductFullPrice)

            }
        }
        .padding()
        .background(.subProductColor)
        .cornerRadius(CornerRadius.l)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.l)
                .stroke(Color.yellow, lineWidth: selected ? 2 : .zero)
        )
    }
}
