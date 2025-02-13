//
//  JSONModel.swift
//  Ruty
//
//  Created by 정성희 on 2/12/25.
//

import Foundation

class JSONModel {
    struct TodayRoutine: Codable {
        let message: String
        let data: [Routine]
    }

    struct Routine: Codable {
        let routineId: Int
        let title: String
        let category: String
        let done: Bool
    }
}
