//
//  JSONModel.swift
//  Ruty
//
//  Created by 정성희 on 2/12/25.
//

import Foundation

class JSONModel {
    
    struct RoutineProgressResponses: Codable {
        let message: String
        let data: RoutineProgressResponse
    }

    struct RoutineProgressResponse: Codable {
        let totalCount: Int
        let completedCount: Int
        let streakCount: Int
    }
    
    struct RoutineHistoryResponses: Codable {
        let message: String
        let data: [RoutineHistoryResponse]
    }

    struct RoutineHistoryResponse: Codable {
        let date: String
        let isDone: Bool
    }
    
    struct AllGoal: Codable {
        let message: String
        let data: [Goal]
    }

    struct Goal: Codable {
        let id: Int
        let category: String
        let content: String
    }
    
    struct CustomGoalSetting: Encodable {
        let title: String
        let description: String
        let weekList: [String]
        let category : String
        let month: Int
    }
    
    struct RoutineHistory: Encodable {
        let routineId: Int
        let year: Int
        let month: Int
    }
    
    struct Login: Encodable {
        let platformType: String
        let code: String
    }
    
    struct LoginResponse: Codable {
        let message: String
        let data: TokenData
    }
    
    struct TokenData: Codable {
        let accessToken: String
        let refreshToken: String
    }
    
    struct SingIn: Encodable {
        let nickName: String
        let isAgree: Bool
    }
    
    struct SignResponse: Codable {
        let message: String
        let data: Bool?
    }
    
    struct APIResponse: Codable {
        let message: String
        let data: Int
    }
    
    struct RoutinesResponse: Codable {
        let message: String
        let data: [Routine]
    }

    struct Routine: Codable {
        let routineId: Int
        let title: String
        let category: String
        let done: Bool
    }
    
    struct RecommendedRoutinesResponse: Codable {
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
    
    struct Delete: Encodable {
        let code: String
    }
    
    struct GoalSettingResponse: Codable {
        let message: String
        let data: Int
    }
    
    struct UserInfoResponse: Codable {
        let message: String
        let data: UserInfo
    }

    struct UserInfo: Codable {
        let memberId: Int
        let email: String
        let nickName: String?
        let name: String?
        let picture: String?
        let isAgree: Bool?
        let socialType: String
        let refreshToken: String
    }
    
    struct AllRoutineResponse: Codable {
        let message: String
        let data: [AllRoutine]
    }

    struct AllRoutine: Codable {
        let routineId: Int
        let title: String
        let description: String
        let weekList: [String]
        let startDate: String
        let endDate: String
        let category: String
        let routineProgress: String
    }
    
    struct MemberInfoDto: Codable {
        let memberId: Int
        let email: String
        let nickName: String
        let name: String?
        let picture: String?
        let isAgree: Bool
        let socialType: String
        let refreshToken: String
    }
}
