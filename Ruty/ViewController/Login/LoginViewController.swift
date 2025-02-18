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
        let dVC = MainHomeViewController()
        let newNavController = UINavigationController(rootViewController: dVC) // 새로운 네비게이션 컨트롤러 생성
        newNavController.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async {
            self.view.window?.rootViewController = newNavController
            self.view.window?.makeKeyAndVisible()
        }
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
            
            // If sign in succeeded, display the app's main content View.
            let email = signInResult?.user.profile?.email ?? ""
            let name = signInResult?.user.profile?.name ?? ""
            
            let user = signInResult?.user
            let idToken = user?.idToken?.tokenString
            let accessToken = user?.accessToken.tokenString
            let refreshToken = user?.refreshToken.tokenString
            
            print("idtoken: \(idToken!)")
            
            let url = NetworkManager.shared.getRequestURL(api: "/login/oauth2/code/google")
            
            let param = NetworkManager.GoogleLogin(platformType: "ios", code: idToken!)
            guard let jsonData = try? JSONEncoder().encode(param),
                  var param = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else { return }
            
            NetworkManager.shared.requestAPI(url: url, method: .post, encoding: JSONEncoding.default , param: param) { result in
                
                switch result {
                case .success(let data):
                    // 성공적으로 데이터를 받았을 경우
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("응답 데이터: \(jsonString)")
                    } else {
                        print("데이터 변환 실패")
                    }
                    
                case .failure(let error):
                    // 요청이 실패한 경우
                    print("API 요청 실패: \(error.localizedDescription)")
                }
            }
            
//            let param : Parameters = ["code" : idToken!]
//            NetworkManager.shared.requestAPI(url: url, method: .post, encoding: URLEncoding.queryString, param: param) { data in
//                print("받은 데이터 : \(data)")
//            }

            print(email)
            print(name)
            
            // 회원가입 창으로 이동
            self.moveToSignUp()
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
    
    private func startGoogleLogin() {
        
        //https://accounts.google.com/o/oauth2/auth?client_id=[클라이언트ID]
        //&redirect_uri=https://localhost:8080/auth/google/callback&response_type=code
        
        let clientID = "940269824042-2u959abkgam4bs5lbuv2nlrvni0hqgss.apps.googleusercontent.com"
        let redirectURI = "ruty://callback"
        let authURL = "https://accounts.google.com/o/oauth2/auth"
        let scope = "name email"
        
        let urlString = URL(string: "\(authURL)?response_type=code&client_id=\(clientID)&redirect_uri=\(redirectURI)")!
        
        // URL 인코딩 처리 (scope, redirect_uri 등)
        let encodedRedirectURI = redirectURI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let encodedScope = scope.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let authURLString = "\(authURL)?client_id=\(clientID)&redirect_uri=\(encodedRedirectURI)&response_type=code"
        
        if let url = URL(string: authURLString) {
            UIApplication.shared.open(url)
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
    }
    
    // Apple ID 로그인에 성공한 경우, 사용자의 인증 정보를 확인하고 필요한 작업을 수행합니다
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            // 매번 인증시 얻을 수 있는 정보
            let userIdentifier = appleIdCredential.user
            
            // 첫 로그인시에만 얻을 수 있는 정보
            let fullName = appleIdCredential.fullName
            let email = appleIdCredential.email
            
            // 토큰 생성 및 삭제에 필요한 데이터
            // 서버와 연결 필요
            let identityToken = appleIdCredential.identityToken // 5분 후 사용불가
            let authorizationCode = appleIdCredential.authorizationCode // 10분 후 사용불가, 한번만 사용가능
            
            if let authorizationCodeData = appleIdCredential.authorizationCode,
               let authorizationCodeString = String(data: authorizationCodeData, encoding: .utf8) {
 
                let url = NetworkManager.shared.getRequestURL(api: "/login/oauth2/code/apple")
                let param : Parameters = ["code" : authorizationCodeString]
                
                NetworkManager.shared.requestAPI(url: url, method: .get, encoding: URLEncoding.queryString, param: param) { data in
                    print("받은 데이터 : \(data)")
                    
                    // 회원가입 창으로 이동
                    self.moveToSignUp()
                    
                    // 디버깅용
//                    let dVC = MainHomeViewController()
//                    let newNavController = UINavigationController(rootViewController: dVC) // 새로운 네비게이션 컨트롤러 생성
//                    newNavController.modalPresentationStyle = .fullScreen
//                    
//                    DispatchQueue.main.async {
//                        self.view.window?.rootViewController = newNavController
//                        self.view.window?.makeKeyAndVisible()
//                    }
                }
            } else {
                print("authorizationCode 변환에 실패했습니다.")
            }
            
            print("Apple ID 로그인에 성공하였습니다.")
            print("사용자 ID: \(userIdentifier)")
            print("전체 이름: \(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")
            print("이메일: \(email ?? "")")
            print("Token: \(identityToken!)")

        default: break
            
        }
    }
}
