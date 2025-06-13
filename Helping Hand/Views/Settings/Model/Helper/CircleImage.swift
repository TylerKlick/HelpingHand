//
//  CircleImage.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/12/25.
//

import SwiftUI

struct CircleImage: View {
    
    let image: Image
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 20)
                .frame(maxWidth: 370, maxHeight: 100)
                .foregroundStyle(.gray)
                .opacity(0.2)
                .brightness(0.1)
            
            HStack {
                image
                    .resizable()
                    .frame(maxWidth: 75, maxHeight: 75)
                    .foregroundStyle(.blue)
                    .clipShape(Circle())
                    .padding(.leading, 35)
                    .padding(.trailing, 10)
                Text("Sign in")
                
                Spacer()
            }
        }
    }
}

#Preview {
    CircleImage(image: Image(systemName: "person.fill"))
}
