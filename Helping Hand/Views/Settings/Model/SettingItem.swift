//
//  SettingItem.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/13/25.
//

import Foundation

struct SettingItem: Identifiable, Hashable {
    let id = UUID()
    let systemImageName: String
    let title: String
    let backgroundColor: Color
}
