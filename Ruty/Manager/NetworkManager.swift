//
//  NetworkManager.swift
//  Ruty
//
//  Created by 정성희 on 2/8/25.
//

import Foundation
import Alamofire

class NetworkManager {
    
    struct SingIn: Encodable {
        let nickName: String
        let isAgree: Bool
    }
    
    static let shared = NetworkManager()
    
    private init() { }
    
    func getURL(api: String) -> String {
        let url = "https://" + (Bundle.main.infoDictionary?["BASE_API"] as! String) + (Bundle.main.infoDictionary?[api] as! String)
        return url
    }
    
    func requestAPI(url: String, method: HTTPMethod, param: [String : Any], completion : @escaping (Data?) -> ()) {
        let accessToken = Bundle.main.infoDictionary?["ACCESS_TOKEN"] as! String
        let header: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type":"application/json", "Accept":"application/json"
        ]
        
        AF.request(url,
                   method: method,
                   parameters: param,
                   encoding: JSONEncoding.default,
                   headers: header)
        .validate(statusCode: 200..<300)
        .responseData { response in
            switch response.result {
            case .success(let data):
                // Data를 문자열로 변환하여 출력
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("JSON 문자열: \(jsonString)")
                } else {
                    print("Data를 문자열로 변환할 수 없습니다.")
                }
                completion(data)
                
            case .failure(let error):
                print("네트워크 api 요청 실패: \(error)")
            }
        }
        
//        if let params = param {
//            
//        }
//        else { let param : Bool? = nil }
//        
        
    }
}


