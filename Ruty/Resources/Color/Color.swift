//
//  Color.swift
//  Ruty
//
//  Created by 정성희 on 2/7/25.
//

import Foundation
import UIKit

extension UIColor {
    // 이미지 컬러 정의
    struct RoutineCategoryColor {
        static let background = UIColor(243, 244, 246, 1)
        static let house = UIColor(254, 205, 211, 1)
        static let money = UIColor(224, 231, 255, 1)
        static let leisure = UIColor(153, 246, 228, 1)
        static let selfcare = UIColor(254, 215, 170, 1)
    }
    
    struct background {
        static let secondary = UIColor(243, 244, 246, 1)
        static let tertiary = UIColor(249, 250, 251, 1)
    }
    
    struct font {
        static let primary = UIColor(3, 7, 18, 1)
        static let secondary = UIColor(107, 114, 128, 1)
        static let tertiary = UIColor(156, 163, 175, 1)
        static let disabled = UIColor(156, 163, 175, 1)
        static let success = UIColor(13, 148, 136, 1)
        static let warning = UIColor(234, 88, 12, 1)
        static let brandStrong = UIColor(67, 56, 202, 1)
    }
    
    struct fill {
        static let brand = UIColor(99, 102, 241, 1)
        static let secondary = UIColor(243, 244, 246, 1)
        static let primary = UIColor(31, 41, 55, 1)
        static let disabled = UIColor(229, 231, 235, 1)
        static let success = UIColor(204, 251, 241, 1)
        static let warning = UIColor(255, 237, 213, 1)
        static let brandTertiary = UIColor(224, 231, 255, 1)
    }
    
    struct border {
        static let secondary = UIColor(209, 213, 219, 1)
        static let primary = UIColor(229, 231, 235, 1)
    }
}
