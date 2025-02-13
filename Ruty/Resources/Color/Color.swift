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
    }
    
    struct font {
        static let primary = UIColor(3, 7, 18, 1)
        static let secondary = UIColor(107, 114, 128, 1)
    }
    
    struct fill {
        static let brand = UIColor(99, 102, 241, 1)
        static let secondary = UIColor(243, 244, 246, 1)
    }
}
