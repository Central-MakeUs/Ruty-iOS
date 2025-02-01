//
//  RoutineDataModel.swift
//  Ruty
//
//  Created by 정성희 on 1/29/25.
//

import Foundation
import Alamofire

// 서버에서 주는 데이터 구조체
struct Routines: Codable {
    let message: String
    let data: [Routine]
}
struct Routine: Codable {
    let id: Int
    let title: String
    let description: String
    let category: String
}

// ImproveSelectDataModel 데이터 접근 가능한 클래스
class RoutineDataProvider {
    static let shared = RoutineDataProvider()
    
    private init() { }
    
    struct GPT: Encodable {
        let prompt: String
    }
    
    private var rawRoutinesData = Routines(message: "", data: [])
    private var routinesData = [[Routine]](repeating: [Routine](), count: 4)
    
    // 인스턴스 생성
    let param = GPT(prompt: "안정적인 주거환경 만들기, 규칙적이고 건강한 생활 리듬 만들기, 합리적이고 계획적인 소비 습관 만들기")
    
    func loadRoutinesData() -> [[Routine]] { return routinesData }
    
    func startloadAIData(completion: @escaping () -> ()) {
        let url = "https://" + (Bundle.main.infoDictionary?["BASE_API"] as! String) + (Bundle.main.infoDictionary?["CHAT"] as! String)
        // Encodable을 JSON으로 변환
        guard let jsonData = try? JSONEncoder().encode(param),
              let param = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else { return }
        
        requestGetAPI(url: url, param: param) {
            self.devideRoutines()
            completion()
        }
    }
    
    // 카테고리 별로 루틴 데이터 분리
    private func devideRoutines() {
        for routine in rawRoutinesData.data {
            switch routine.category {
            case "HOUSE":
                routinesData[0].append(routine)
            case "MONEY":
                routinesData[1].append(routine)
            case "LEISURE":
                routinesData[2].append(routine)
            case "SELFCARE":
                routinesData[3].append(routine)
            default: break
            }
        }
    }
    
    private func requestGetAPI(url: String, param: [String : Any], completion :@escaping ()->()) {
        
        let accessToken = Bundle.main.infoDictionary?["ACCESS_TOKEN"] as! String
        let header: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type":"application/json", "Accept":"application/json"
        ]
        
        AF.request(url,
                   method: .get,
                   parameters: param,
                   encoding: URLEncoding.default,
                   headers: header)
        .validate(statusCode: 200..<300)
        .responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(Routines.self, from: data)
                    let routines = decodedResponse  // 실제 루틴 데이터
                    self.rawRoutinesData = routines
                    completion()
                } catch {
                    print("JSON 디코딩 오류: \(error)")
                }
            case .failure(let error):
                print("네트워크 api 요청 실패: \(error)")
            }
        }
    }
}

