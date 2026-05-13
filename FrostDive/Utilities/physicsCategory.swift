//
//  physicsCategory.swift
//  FrostDive
//
//  Created by Ibnu Taufick Ahraza on 13/05/26.
//

import Foundation

struct physicsCategory {
    static let none: UInt32 = 0
    static let submarine: UInt32 = 1 << 0
    static let trash: UInt32 = 1 << 1
    static let obstacle: UInt32 = 1 << 2
    static let edge: UInt32 = 1 << 3
    static let power: UInt32 = 1 << 4
}
