//
//  JSONModel.swift
//  Ruty
//
//  Created by 정성희 on 2/12/25.
//

import Foundation

class JSONModel {
    
    struct GoogleLogin: Encodable {
        let platformType: String
        let code: String
    }
    
    struct GoogleLoginResponse: Codable {
        let message: String
        let data: GoogleTokenData
    }

    struct GoogleTokenData: Codable {
        let accessToken: String
        let refreshToken: String
    }
    
    struct AppleLogin: Encodable {
        let platformType: String
        let code: String
    }
    
    struct AppleLoginResponse: Codable {
        let message: String
        let data: AppleTokenData
    }
    
    struct AppleTokenData: Codable {
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
    
    struct GoogleUserInfoResponse: Codable {
        let message: String
        let data: GoogleUserInfo
    }

    struct GoogleUserInfo: Codable {
        let memberId: Int
        let email: String
        let nickName: String
        let name: String
        let picture: String?
        let isAgree: Bool
        let socialType: String
        let refreshToken: String
    }
    
    struct AppleUserInfoResponse: Codable {
        let message: String
        let data: AppleUserInfo
    }

    struct AppleUserInfo: Codable {
        let memberId: Int
        let email: String
        let nickName: String
        let name: String?
        let picture: String?
        let isAgree: Bool
        let socialType: String
        let refreshToken: String
    }
    
    struct AppleAllRoutineResponse: Codable {
        let message: String
        let data: [AppleAllRoutine]
    }

    struct AppleAllRoutine: Codable {
        let routineId: Int
        let title: String
        let description: String
        let weekList: [String]
        let startDate: String
        let endDate: String
        let category: String
        let memberInfoDto: AppleMemberInfoDto
    }

    struct AppleMemberInfoDto: Codable {
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
