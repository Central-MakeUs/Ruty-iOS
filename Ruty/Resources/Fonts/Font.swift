//
//  Font.swift
//  Ruty
//
//  Created by 정성희 on 1/11/25.
//

import Foundation

enum Font : String {
    case regular = "Pretendard-Regular"
    case bold = "Pretendard-Bold"
    case light = "Pretendard-Light"
    case medium = "Pretendard-Medium"
    case semiBold = "Pretendard-SemiBold"
    case thin = "Pretendard-Thin"
    case extraLight = "Pretendard-ExtraLight"
    case extraBold = "Pretendard-ExtraBold"
    case black = "Pretendard-Black"
}

let categoryIndex: [String: Int] = [
    "HOUSE": 0,
    "MONEY": 1,
    "LEISURE": 2,
    "SELFCARE": 3
]

let categoryUIString: [String: String] = [
    "HOUSE": "주거",
    "MONEY": "소비",
    "LEISURE": "여가생활",
    "SELFCARE": "자기관리"
]

let categoryServerString: [String: String] = [
    "주거": "HOUSE",
    "소비": "MONEY",
    "여가생활": "LEISURE",
    "자기관리": "SELFCARE"
]
