//
//  User.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/12/25.
//

import Foundation
import SwiftUI

/// Representation of User data
struct User: Codable, Hashable {
    var id: UUID
    var username: String
    var email: String
    var profilePictureURL: URL?
}
