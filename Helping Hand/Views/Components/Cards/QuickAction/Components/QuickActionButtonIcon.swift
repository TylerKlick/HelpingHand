//
//  QuickActionButtonIcon.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI

struct QuickActionButtonIcon: View {
    let icon: String
    let iconColor: Color
    let isEnabled: Bool
    
    var body: some View {
        Image(systemName: icon)
            .font(.title3)
            .foregroundColor(isEnabled ? iconColor : .gray)
    }
}
