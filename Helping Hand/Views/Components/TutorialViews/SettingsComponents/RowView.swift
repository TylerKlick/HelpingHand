//
//  RowView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/13/25.
//

import SwiftUI

struct RowView: View, Identifiable {
    let id: UUID = UUID()
    let systemImageName: String
    let title: String
    let backgroundColor: Color
    var fillWidth: Bool = true
    var destination: AnyView = AnyView(EmptyView())

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
                .padding(16)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))


            Text(title)
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)

            Spacer()
        }
        .padding()
        .frame(maxWidth: fillWidth ? .infinity : nil, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.gray).opacity(0.15))
        )
    }
}
