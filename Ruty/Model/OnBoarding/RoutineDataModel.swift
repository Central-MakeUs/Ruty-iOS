//
//  RoutineDataModel.swift
//  Ruty
//
//  Created by 정성희 on 1/29/25.
//

import Foundation
import Alamofire

// ImproveSelectDataModel 데이터 접근 가능한 클래스
class RoutineDataProvider {
    static let shared = RoutineDataProvider()
    
    private init() { }
    
    struct GPT: Encodable {
        let prompt: String
    }
    
    private var rawRoutinesData = JSONModel.RecommendedRoutines(message: "", data: [])
    private var routinesData = [[JSONModel.RecommendedRoutine]](repeating: [JSONModel.RecommendedRoutine](), count: 4)
    
    private var param: GPT?
    
    func setGPTParam(prompt: String) {
        param = GPT(prompt: prompt)
    }
    
    func loadRoutinesData() -> [[JSONModel.RecommendedRoutine]] { return routinesData }
    
    func startloadAIData(completion: @escaping () -> ()) {
        let url = "https://" + (Bundle.main.infoDictionary?["BASE_API"] as! String) + (Bundle.main.infoDictionary?["CHAT"] as! String)
        // Encodable을 JSON으로 변환
        guard let jsonData = try? JSONEncoder().encode(param),
              let param = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else { return }
        print("gpt Request Params: \(param)")
        
        requestGetAPI(url: url, param: param) {
            self.devideRoutines()
            completion()
        }
    }
    
    func loadRecommendedData(completion: @escaping () -> ()) {
        print()
        
        let url = NetworkManager.shared.getRequestURL(api: "/api/recommend/my")
        NetworkManager.shared.requestAPI(url: url, method: .get, encoding: URLEncoding.default, param: nil) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.RecommendedRoutines.self, from: data)
                    self.rawRoutinesData = decodedResponse
                    self.devideRoutines()
                    
                    completion()
                } catch {
                    print("JSON 디코딩 오류: \(error)")
                }
            case .failure(let error):
                print("네트워크 api 요청 실패: \(error)")
            }
        }
    }
    
    // 카테고리 별로 루틴 데이터 분리
    private func devideRoutines() {
        // routinesData 초기화
        routinesData = [[JSONModel.RecommendedRoutine]](repeating: [JSONModel.RecommendedRoutine](), count: 4)
        
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
    
    private func requestGetAPI(url: String, param: Parameters, completion :@escaping ()->()) {
        
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
                    let decodedResponse = try JSONDecoder().decode(JSONModel.RecommendedRoutines.self, from: data)
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

