//
//  SplashViewController.swift
//  Ruty
//
//  Created by 정성희 on 3/5/25.
//

import UIKit
import Alamofire

class SplashViewController: UIViewController {
    
    private let rutyLogo = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "Ruty-img")
    }
    
    private let rutyTitle = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "Ruty-title")
    }
    
    var isRecommendDataExist : Bool?
    var isRoutineDataExist : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("스플래시 뷰 로드")
        
        
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        performAutoLogin()
    }
    
    deinit {
        print("SplashViewController deinitialized")
    }
    
    func performAutoLogin() {
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            print("토큰이 없음")
            // 토큰이 없다면 로그인 화면으로 이동
            moveToLoginView()
            return
        }
        
        isTokenValid { isTokenValid in
            if isTokenValid {
                print("토큰이 존재하며 유효함")
                RoutineDataProvider.shared.isRecommendedEver { isExist in
                    self.isRecommendDataExist = isExist
                    if self.isRoutineDataExist != nil { self.controlToLoginOrMain() }
                } routineCompletion: { isExist in
                    self.isRoutineDataExist = isExist
                    if self.isRecommendDataExist != nil { self.controlToLoginOrMain() }
                }
            }
            else {
                print("토큰이 존재하지만 유효하지 않음")
                print("refresh token 요청 시작")
                self.refreshAccessToken()
            }
        }
    }
    
    func controlToLoginOrMain() {
        guard let isRecommendDataExist = isRecommendDataExist, let isRoutineDataExist = isRoutineDataExist else { return }
        
        // 추천받은 루틴이 없는 경우 (회원가입 한 후 추천받지 않고 바로 앱 종료 한 경우)
        if !isRecommendDataExist && !isRoutineDataExist {
            moveToLoginView()
        }
        else {
            moveToMainView() // 메인화면으로 이동
        }
    }
    
    func moveToLoginView() {
        let nextVC = LoginViewController()
        DispatchQueue.main.async {
            self.view.window?.rootViewController = nextVC
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    func moveToMainView() {
        let nextVC = MainHomeViewController()
        let newNavController = UINavigationController(rootViewController: nextVC)
        newNavController.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async {
            self.view.window?.rootViewController = newNavController
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    func isTokenValid(onColpleted: @escaping (Bool) -> ()){
        let url = NetworkManager.shared.getRequestURL(api: "/api/member/isAgree")
        NetworkManager.shared.requestAPI(url: url, method: .get, encoding: URLEncoding.default, param: nil) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.SignResponse.self, from: data)
                    print("decodedResponse : \(decodedResponse)")
                    
                    if decodedResponse.message == "ok" {
                        onColpleted(true)
                    }
                    else {
                        onColpleted(false)
                    }
                } catch {
                    print("JSON 디코딩 오류: \(error)")
                    onColpleted(false)
                }
            case .failure(let error):
                // 요청이 실패한 경우
                print("API 요청 실패: \(error.localizedDescription)")
                onColpleted(false)
            }
        }
    }
    
    func refreshAccessToken() {
        let url = NetworkManager.shared.getRequestURL(api: "/api/member/isAgree")
        NetworkManager.shared.requestRefeshAccessTokenAPI(url: url, method: .get, encoding: URLEncoding.default, param: nil) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("모든 루틴 JSON 문자열: \(jsonString)")
                    } else {
                        print("Data를 문자열로 변환할 수 없습니다.")
                    }
                    let decodedResponse = try JSONDecoder().decode(JSONModel.LoginResponse.self, from: data)
                    if decodedResponse.message == "ok" {
                        UserDefaults.standard.set(decodedResponse.data.accessToken, forKey: "accessToken")
                        UserDefaults.standard.set(decodedResponse.data.refreshToken, forKey: "refreshToken")
                        //LoginViewController.shared.splashVC = self
                        //LoginViewController.shared.loadMemberAgree()
                        
                        RoutineDataProvider.shared.isRecommendedEver { isExist in
                            self.isRecommendDataExist = isExist
                            if self.isRoutineDataExist != nil { self.controlToLoginOrMain() }
                        } routineCompletion: { isExist in
                            self.isRoutineDataExist = isExist
                            if self.isRecommendDataExist != nil { self.controlToLoginOrMain() }
                        }
                    }
                    else {
                        print("서버 연결 오류")
                        self.moveToLoginView()
                    }
                } catch {
                    print("JSON 디코딩 오류: \(error)")
                    self.moveToLoginView()
                }
            case .failure(let error):
                // 요청이 실패한 경우
                print("API 요청 실패: \(error.localizedDescription)")
                self.moveToLoginView()
            }
        }
    }
    
    func setLayout() {
        [rutyLogo, rutyTitle].forEach({ view.addSubview($0) })

        self.rutyLogo.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(207)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(150)
        }
        self.rutyTitle.snp.makeConstraints {
            $0.top.equalTo(rutyLogo.snp.bottom).offset(7)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(88.23)
            $0.height.equalTo(34.47)
        }
    }
    
}
