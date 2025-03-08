//
//  NetworkManager.swift
//  Ruty
//
//  Created by 정성희 on 2/8/25.
//

import Foundation
import Alamofire

class NetworkManager {
    
    static let shared = NetworkManager()
    private init() { }
    
    func getRequestURL(api: String) -> String {
        let url = "https://" + (Bundle.main.infoDictionary?["BASE_API"] as! String) + api
        return url
    }
    // param: [String : Any]
    // request body or param 만 있는 경우
    // JSONEncoding.default: 주로 POST, PUT 등의 요청에서 사용하며, 파라미터를 JSON 형태의 본문에 인코딩합니다.
    // URLEncoding.default: GET 요청에서 URL에 파라미터를 추가하는 데 사용, 쿼리 파라미터를 url 에 추가하는 경우
    func requestAPI(url: String, method: HTTPMethod, encoding: ParameterEncoding, param: Parameters?, completion : @escaping (Result<Data, Error>) -> Void) {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        let header: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type":"application/json", "Accept":"application/json"
        ]
        
        AF.request(url,
                   method: method,
                   parameters: param ?? nil,
                   encoding: encoding,
                   headers: header)
        .validate(statusCode: 200..<300)
        .responseData { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // param, body 모두 있는 경우
    func sendRequest(url: String, method: String, jsonBody: [String : Any], completion : @escaping (Result<Data, Error>) -> Void) {
        // access token 가져오기 및 헤더 구성
        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        guard let url = URL(string: url) else {
            print("URL 생성 실패")
            return
        }
        
        // URLRequest 생성
        var request = URLRequest(url: url)
        request.httpMethod = method // 혹은 서버에서 요구하는 HTTP 메서드 사용
        headers.forEach { header in
            request.setValue(header.value, forHTTPHeaderField: header.name)
        }
        
        do {
            // JSON 인코딩하여 HTTP Body에 설정
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        } catch {
            print("JSON 인코딩 오류: \(error)")
            return
        }
        
        AF.request(request)
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    
    func requestRefeshAccessTokenAPI(url: String, method: HTTPMethod, encoding: ParameterEncoding, param: Parameters?, completion : @escaping (Result<Data, Error>) -> Void) {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") ?? ""
        print("refreshToken: \(refreshToken)")
        let header: HTTPHeaders = [
            "Authorization-refresh": "Bearer \(refreshToken)",
            "Content-Type":"application/json", "Accept":"application/json"
        ]
        
        AF.request(url,
                   method: method,
                   parameters: param ?? nil,
                   encoding: encoding,
                   headers: header)
        .validate(statusCode: 200..<300)
        .responseData { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
