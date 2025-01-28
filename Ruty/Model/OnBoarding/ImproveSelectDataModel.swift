//
//  ImproveSelectDataModel.swift
//  Ruty
//
//  Created by 정성희 on 1/23/25.
//

import Foundation

// 서버에서 받을 데이터
struct ImproveSelectModel {
    let content: String
}

// ImproveSelectDataModel 데이터 접근 가능한 클래스
class ImproveSelectDataProvider {
    static let shared = ImproveSelectDataProvider()
    
    private init() { }
    
    func fetchData() -> [ImproveSelectModel] {
        return [
            ImproveSelectModel(content: "안정적인 주거 환경 만들기"),
            ImproveSelectModel(content: "정기적인 집 관리로 편안함 유지하기"),
            ImproveSelectModel(content: "합리적이고 계획적인 소비 습관 만들기"),
            ImproveSelectModel(content: "균형 잡힌 식습관 꾸준히 유지하기"),
            ImproveSelectModel(content: "규칙적이고 건강한 생활 리듬 만들기"),
            ImproveSelectModel(content: "외로움과 고립감 해소하기"),
            ImproveSelectModel(content: "스스로를 돌보고 가꿔 더 나은 나 되기"),
            ImproveSelectModel(content: "일과 여가의 조화로 균형 있는 삶 살기")
        ]
    }
}
