//
//  JSONModel.swift
//  Ruty
//
//  Created by 정성희 on 2/12/25.
//

import Foundation

class JSONModel {
    struct Routines: Codable {
        let message: String
        let data: [Routine]
    }

    struct Routine: Codable {
        let routineId: Int
        let title: String
        let category: String
        let done: Bool
    }
    
    struct RecommendedRoutines: Codable {
        let message: String
        let data: [RecommendedRoutine]
    }
    struct RecommendedRoutine: Codable {
        let id: Int
        let title: String
        let description: String
        let category: String
    }
}
