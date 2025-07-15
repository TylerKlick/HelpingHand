//
//  CustomTabItem.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI

struct CustomTabItem: Identifiable, Hashable {
    let id = UUID()
    let systemImageName: String
    let title: String
    let backgroundGradient: LinearGradient
    let content: AnyView
    
    init(systemImageName: String, title: String, backgroundGradient: LinearGradient, @ViewBuilder content: @escaping () -> some View) {
        self.systemImageName = systemImageName
        self.title = title
        self.backgroundGradient = backgroundGradient
        self.content = AnyView(content())
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CustomTabItem, rhs: CustomTabItem) -> Bool {
        lhs.id == rhs.id
    }
}
