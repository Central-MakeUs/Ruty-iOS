//
//  JSONModel.swift
//  Ruty
//
//  Created by 정성희 on 2/12/25.
//

import Foundation

class JSONModel {
    
    struct GoogleLoginResponse: Codable {
        let message: String
        let data: TokenData
    }

    struct TokenData: Codable {
        let accessToken: String
        let refreshToken: String
    }
    
    struct Sign: Codable {
        let message: String
        let data: Bool?
    }
    
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
    
    struct CategoryLevels: Codable {
        let message: String
        let data: [CategoryLevel]
    }

    struct CategoryLevel: Codable {
        let category: String
        let level: Int
        let totalPoints: Int
    }
    
    struct CategoryLevelAfterRoutineDone: Codable {
        let message: String
        let data: CategoryLevel
    }
}
