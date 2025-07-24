//
//  CardHeader.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI

// MARK: - Card Header
struct CardHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .opacity(0.95)
            Spacer()
        }
    }
}
