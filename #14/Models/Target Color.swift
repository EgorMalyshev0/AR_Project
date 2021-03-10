//
//  Target Color.swift
//  #14
//
//  Created by Egor Malyshev on 10.03.2021.
//

import UIKit

enum TargetColor: Int, CaseIterable {
    case red
    case blue
    case green
    case yellow
    case purple
    case orange
    
    var color: UIColor {
        switch self {
        case .blue:
            return UIColor.blue
        case .red:
            return UIColor.red
        case .green:
            return UIColor.green
        case .yellow:
            return UIColor.yellow
        case .purple:
            return UIColor.purple
        case .orange:
            return UIColor.orange
        }
    }
    static var random: UIColor {
        return TargetColor(rawValue: Int.random(in: 0...TargetColor.allCases.count - 1))?.color ?? TargetColor.red.color
    }
}
