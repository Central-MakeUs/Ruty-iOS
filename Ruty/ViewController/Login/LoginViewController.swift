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
    
    private let RutyIcon = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "Ruty-img")
    }
    
    private let RutyLogo = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "Ruty-title")
    }
    
    private let googleLoginView = UIView().then {
        $0.backgroundColor = UIColor.fill.secondary
        $0.layer.cornerRadius = 16
        $0.isUserInteractionEnabled = true
    }
    
    let googleStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
        $0.distribution = .equalCentering
    }
    
    private let googleLoginLabel = UILabel().then {
        $0.text = "Google로 로그인"
        $0.textColor = UIColor.font.primary
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.numberOfLines = 1
    }
    
    private let googleLoginLabelLogo = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "Logo-Google")
    }
    
    private let appleLoginView = UIView().then {
        $0.backgroundColor = UIColor.fill.secondary
        $0.layer.cornerRadius = 16
        $0.isUserInteractionEnabled = true
    }
    
    let appleStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
        $0.distribution = .equalCentering
    }
    
    private let appleLoginLabel = UILabel().then {
        $0.text = "Apple로 로그인"
        $0.textColor = UIColor.font.primary
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.numberOfLines = 1
    }
    
    private let appleLoginLabelLogo = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "Logo-Apple")
    }
    
//    private let appleLoginBtn = ASAuthorizationAppleIDButton(authorizationButtonType: .continue, authorizationButtonStyle: .white).then {
//        $0.cornerRadius = 10
//        $0.addTarget(self, action: #selector(tapAppleLoginBtn), for: .touchUpInside)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        setLayout()
        
        let googleTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGoogleLoginBtn(_:)))
        googleLoginView.addGestureRecognizer(googleTapGesture)
        
        let appleTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAppleLoginBtn(_:)))
        appleLoginView.addGestureRecognizer(appleTapGesture)
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
        [RutyIcon, RutyLogo, googleLoginView, appleLoginView].forEach({ view.addSubview($0) })
        [googleStackView, googleLoginLabel, googleLoginLabelLogo].forEach({ googleLoginView.addSubview($0) })
        [appleStackView, appleLoginLabel, appleLoginLabelLogo].forEach({ appleLoginView.addSubview($0) })
        [googleLoginLabelLogo, googleLoginLabel].forEach({ googleStackView.addArrangedSubview($0) })
        [appleLoginLabelLogo, appleLoginLabel].forEach({ appleStackView.addArrangedSubview($0) })

        self.RutyIcon.snp.makeConstraints({
            $0.top.equalToSuperview().inset(207)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(150)
        })
        
        self.RutyLogo.snp.makeConstraints({
            $0.top.equalTo(RutyIcon.snp.bottom).inset(7)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(34.47)
            $0.width.equalTo(88.23)
        })
        
        self.googleLoginView.snp.makeConstraints({
            $0.bottom.equalTo(appleLoginView.snp.top).offset(-20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(56)
        })

        self.googleStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        self.googleLoginLabelLogo.snp.makeConstraints({
            $0.height.width.equalTo(20)
        })
        
        self.appleLoginView.snp.makeConstraints({
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(56)
        })

        self.appleStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        self.appleLoginLabelLogo.snp.makeConstraints({
            $0.height.width.equalTo(20)
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
                            UserDefaults.standard.set(decodedResponse.data.accessToken, forKey: "accessToken")
                            DataManager.shared.socialType = "GOOGLE"
                            // 로그인 성공
                            // 회원가입 or 메인뷰로 이동
                            self.loadMemberAgree()
                        }
                        else {
                            print("서버 연결 오류")
                            ErrorViewController.showErrorPage(viewController: self)
                        }
                    } catch {
                        print("JSON 디코딩 오류: \(error)")
                        ErrorViewController.showErrorPage(viewController: self)
                    }
                case .failure(let error):
                    // 요청이 실패한 경우
                    print("API 요청 실패: \(error.localizedDescription)")
                    ErrorViewController.showErrorPage(viewController: self)
                }
            }
        }
    }
    
    @objc func tapAppleLoginBtn(_ sender: UIButton) {
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
                        //self.moveToSignUp() // 디버깅용
                        self.moveToMainView() // 메인화면으로 이동
                    }
                } catch {
                    print("JSON 디코딩 오류: \(error)")
                    ErrorViewController.showErrorPage(viewController: self)
                }
            case .failure(let error):
                // 요청이 실패한 경우
                print("회원가입 API 요청 실패: \(error.localizedDescription)")
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
                NetworkManager.shared.requestAPI(url: url, method: .post, encoding: JSONEncoding.default, param: param) { result in
                    switch result {
                    case .success(let data):
                        do {
                            let decodedResponse = try JSONDecoder().decode(JSONModel.AppleLoginResponse.self, from: data)
                            if decodedResponse.message == "ok" {
                                UserDefaults.standard.set(decodedResponse.data.accessToken, forKey: "accessToken")
                                print("Apple 로그인 성공")
                                DataManager.shared.socialType = "APPLE"
                                // 로그인 성공. 회원가입 or 메인뷰로 이동
                                self.loadMemberAgree()
                            }
                            else {
                                print("서버 연결 오류")
                                ErrorViewController.showErrorPage(viewController: self)
                            }
                        } catch {
                            print("JSON 디코딩 오류: \(error)")
                            ErrorViewController.showErrorPage(viewController: self)
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
