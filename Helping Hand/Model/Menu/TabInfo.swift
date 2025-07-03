//
//  TabInfo.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/3/25.
//

import Foundation
import SwiftUI

struct TabInfo: Identifiable {
    let id = UUID()
    let title: String
    let imagePath: String
    let accentColor: Color
    let onTap: () -> Void

}
