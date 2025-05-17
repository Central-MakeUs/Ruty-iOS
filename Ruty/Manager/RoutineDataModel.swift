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
    
    private var rawRoutinesData = JSONModel.RecommendedRoutinesResponse(message: "", data: [])
    private var routinesData = [[JSONModel.RecommendedRoutine]](repeating: [JSONModel.RecommendedRoutine](), count: 4)
    
    private var param: GPT?
    
    func setGPTParam(prompt: String) {
        param = GPT(prompt: prompt)
    }
    
    func loadRoutinesData() -> [[JSONModel.RecommendedRoutine]] { return routinesData }
    
    func startloadAIData(completion: @escaping (Bool) -> ()) {
        let url = "https://" + (Bundle.main.infoDictionary?["BASE_API"] as! String) + (Bundle.main.infoDictionary?["CHAT"] as! String)
        // Encodable을 JSON으로 변환
        guard let jsonData = try? JSONEncoder().encode(param),
              let param = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else { return }
        print("gpt Request Params: \(param)")
        
        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
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
                    let decodedResponse = try JSONDecoder().decode(JSONModel.RecommendedRoutinesResponse.self, from: data)
                    if decodedResponse.message == "created" {
                        let routines = decodedResponse
                        self.rawRoutinesData = routines
                        self.devideRoutines()
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
                } catch {
                    print("JSON 디코딩 오류: \(error)")
                    completion(false)
                }
            case .failure(let error):
                print("네트워크 api 요청 실패: \(error)")
                completion(false)
            }
        }
    }
    
    func loadRecommendedData(completion: @escaping () -> ()) {
        let url = NetworkManager.shared.getRequestURL(api: "/api/recommend/my")
        NetworkManager.shared.requestAPI(url: url, method: .get, encoding: URLEncoding.default, param: nil) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.RecommendedRoutinesResponse.self, from: data)
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
    
    func isRecommendedDataExist(recommendCompletion: @escaping (Bool) -> ()) {
        let url = NetworkManager.shared.getRequestURL(api: "/api/recommend/my")
        NetworkManager.shared.requestAPI(url: url, method: .get, encoding: URLEncoding.default, param: nil) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.RecommendedRoutinesResponse.self, from: data)
                    self.rawRoutinesData = decodedResponse
                    
                    recommendCompletion(!self.rawRoutinesData.data.isEmpty)
                } catch {
                    print("추천 JSON 디코딩 오류: \(error)")
                }
            case .failure(let error):
                print("네트워크 api 요청 실패: \(error)")
            }
        }
    }
    
    func isRoutineDataExist(routineCompletion: @escaping (Bool) -> ()) {
        let url = NetworkManager.shared.getRequestURL(api: "/api/routine")
        NetworkManager.shared.requestAPI(url: url, method: .get, encoding: URLEncoding.default, param: nil) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.AllRoutineResponse.self, from: data)
    
                    routineCompletion(!decodedResponse.data.isEmpty)

                } catch {
                    print("루틴 JSON 디코딩 오류: \(error)")
                }
            case .failure(let error):
                // 요청이 실패한 경우
                print("API 요청 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // 카테고리 별로 루틴 데이터 분리
    func devideRoutines() {
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
}
