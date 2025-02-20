//
//  ViewController.swift
//  Ruty
//
//  Created by 정성희 on 1/8/25.
//

import UIKit
import SnapKit
import Then
import Alamofire
import GoogleSignIn
import AuthenticationServices

class LoginViewController: UIViewController {
    
    let googleLoginBtn = UIButton().then {
        $0.setTitle("Google 로그인", for: .normal)
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 10
        $0.setTitleColor(.white, for: .normal)
        $0.addTarget(self, action: #selector(tapGoogleLoginBtn(_:)), for: .touchUpInside)
    }
    
    private let appleLoginBtn = ASAuthorizationAppleIDButton(authorizationButtonType: .continue, authorizationButtonStyle: .black).then {
        $0.cornerRadius = 10
        $0.addTarget(self, action: #selector(tapAppleLoginBtn), for: .touchUpInside)
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setLayout()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 디버깅 안할땐 주석처리 필수
        //        let secondVC = RoutineViewController()
        //        secondVC.modalPresentationStyle = .fullScreen
        //        self.present(secondVC, animated: true, completion: nil)
        
        // 메인 뷰 디버깅
        // 디버깅 안할땐 주석처리 필수
//        let dVC = MainHomeViewController()
//        let newNavController = UINavigationController(rootViewController: dVC) // 새로운 네비게이션 컨트롤러 생성
//        newNavController.modalPresentationStyle = .fullScreen
//        
//        DispatchQueue.main.async {
//            self.view.window?.rootViewController = newNavController
//            self.view.window?.makeKeyAndVisible()
//        }
    }
    
    func setLayout() {
        [googleLoginBtn, appleLoginBtn].forEach({ view.addSubview($0) })
             
        self.googleLoginBtn.snp.makeConstraints({
            $0.top.equalToSuperview().offset(500)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(56)
        })
        self.appleLoginBtn.snp.makeConstraints({
            $0.top.equalTo(googleLoginBtn.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(56)
        })
    }
    
   
    @objc func tapGoogleLoginBtn(_ sender: UIButton) {
        // SDK 로그인 방식
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            
            let user = signInResult?.user
            let idToken = user?.idToken?.tokenString
            
            let url = NetworkManager.shared.getRequestURL(api: "/login/oauth2/code/google")
            
            let param = JSONModel.GoogleLogin(platformType: "ios", code: idToken!)
            guard let jsonData = try? JSONEncoder().encode(param),
                  var param = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else { return }
                    
            NetworkManager.shared.requestAPI(url: url, method: .post, encoding: JSONEncoding.default , param: param) { result in
                
                switch result {
                case .success(let data):
                    do {
                        let decodedResponse = try JSONDecoder().decode(JSONModel.GoogleLoginResponse.self, from: data)
                        if decodedResponse.message == "ok" {
                            print(decodedResponse)
                            // 로그인 성공
                            // 회원가입 or 메인뷰로 이동
                            self.loadMemberAgree()
                        }
                        else {
                            print("서버 연결 오류")
                            //throw HttpError.badRequest
                            ErrorViewController.showErrorPage(viewController: self)
                        }
                    } catch {
                        print("JSON 디코딩 오류: \(error)")
                    }
                case .failure(let error):
                    // 요청이 실패한 경우
                    print("API 요청 실패: \(error.localizedDescription)")
                    ErrorViewController.showErrorPage(viewController: self)
                }
            }
        }
    }
    
    @objc func tapAppleLoginBtn() {
        // SDK 로그인 방식
        let provider = ASAuthorizationAppleIDProvider()
        let requset = provider.createRequest()
        
        // 사용자에게 제공받을 정보를 선택 (이름 및 이메일)
        requset.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [requset])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func loadMemberAgree() {
        let url = NetworkManager.shared.getRequestURL(api: "/api/member/isAgree")
        NetworkManager.shared.requestAPI(url: url, method: .get, encoding: URLEncoding.default, param: nil) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.SignResponse.self, from: data)
                    // 회원가입이 필요함
                    if decodedResponse.data == nil {
                        self.moveToSignUp() // 회원가입 창으로 이동
                    }
                    
                    // 회원가입 완료됨
                    else {
                        self.moveToSignUp() // 디버깅용
                        //self.moveToMainView() // 메인화면으로 이동
                    }
                } catch {
                    print("JSON 디코딩 오류: \(error)")
                }
            case .failure(let error):
                // 요청이 실패한 경우
                print("API 요청 실패: \(error.localizedDescription)")
                ErrorViewController.showErrorPage(viewController: self)
            }
        }
    }
      
    func moveToSignUp() {
        let secondVC = SignUpAgreeViewController()
        secondVC.modalPresentationStyle = .fullScreen
        
        // UINavigationController 생성
        let navigationController = UINavigationController(rootViewController: secondVC)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
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
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    // 인증창을 보여주기 위한 메서드 (인증창을 보여 줄 화면을 설정)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.view.window ?? UIWindow()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    // 로그인 실패 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("로그인 실패", error.localizedDescription)
        ErrorViewController.showErrorPage(viewController: self)
    }
    
    // Apple ID 로그인에 성공한 경우, 사용자의 인증 정보를 확인하고 필요한 작업을 수행합니다
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            if let authorizationCodeData = appleIdCredential.authorizationCode,
               let authorizationCodeString = String(data: authorizationCodeData, encoding: .utf8) {
                let url = NetworkManager.shared.getRequestURL(api: "/login/oauth2/code/apple")
                let param = JSONModel.AppleLogin(platformType: "ios", code: authorizationCodeString)
                guard let jsonData = try? JSONEncoder().encode(param),
                      var param = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else { return }
                
                UserDefaults.standard.set(authorizationCodeString, forKey: "authCode")
                
                print("애플 로그인 시도")
                NetworkManager.shared.requestAPI(url: url, method: .post, encoding: JSONEncoding.default, param: param) { result in
                    switch result {
                    case .success(let data):
                        do {
                            let decodedResponse = try JSONDecoder().decode(JSONModel.AppleLoginResponse.self, from: data)
                            if decodedResponse.message == "ok" {
                                print(decodedResponse)
                                print("애플 로그인 성공")
                                // 로그인 성공. 회원가입 or 메인뷰로 이동
                                self.loadMemberAgree()
                            }
                            else {
                                print("서버 연결 오류")
                                ErrorViewController.showErrorPage(viewController: self)
                            }
                        } catch {
                            print("JSON 디코딩 오류: \(error)")
                        }
                    case .failure(let error):
                        // 요청이 실패한 경우
                        print("API 요청 실패: \(error.localizedDescription)")
                        ErrorViewController.showErrorPage(viewController: self)
                    }
                }
            } else {
                print("authorizationCode 변환에 실패했습니다.")
            }

        default: break
        }
    }
}
