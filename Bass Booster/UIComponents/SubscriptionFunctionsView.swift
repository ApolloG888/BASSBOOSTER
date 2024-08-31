//
//  SubscriptionFunctionsView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 31.08.2024.
//

import SwiftUI

struct SubscriptionFunctionsView: View {
    var restoreAction: (() -> Void)?
    var body: some View {
            HStack {
                Button(action: {
                    // open google.com
                }) {
                    Text("Privacy Policy")
                        .font(.sfProText(size: 11))
                    
                }
                
                Spacer()
                
                Rectangle()
                    .frame(width: 1, height: 20)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    restoreAction?()
                }) {
                    Text("Restore")
                        .font(.sfProText(size: 11))
                }
                
                Spacer()
                
                Rectangle()
                    .frame(width: 1, height: 20)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    // open google.com
                }) {
                    Text("Terms of use")
                        .font(.sfProText(size: 11))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 40)
    }
}

#Preview {
    SubscriptionFunctionsView()
        .background(Color.black)
}
