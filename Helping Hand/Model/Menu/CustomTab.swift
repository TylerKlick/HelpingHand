//
//  TabInfo.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/3/25.
//

import Foundation
import SwiftUI

struct CustomTab<Content: View>: Identifiable {
    let id = UUID()
    let title: String
    let image: String
    let accentColor: Color
    let content: Content

    init(title: String, image: String, accentColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.image = image
        self.accentColor = accentColor
        self.content = content()
    }
}
