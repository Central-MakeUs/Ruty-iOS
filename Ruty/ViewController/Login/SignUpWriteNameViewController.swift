//
//  SignUpWriteNameViewController.swift
//  Ruty
//
//  Created by 정성희 on 1/13/25.
//

import UIKit
import Alamofire

class SignUpWriteNameViewController: UIViewController {

    private let maxLength = 20
    var isAgree = false
    
    let navigationView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let progressBarView = ProgressBarView().then {
        $0.layer.cornerRadius = 4
    }
    
    let backBtn = UIButton().then {
        $0.setImage(UIImage(named: "back"), for: .normal)
    }
    
    let titleLabel1 = UILabel().then {
        $0.text = "반가워요!"
        $0.textColor = UIColor(3, 7, 18, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 24)
        $0.numberOfLines = 1
    }
    
    let titleLabel2 = UILabel().then {
        $0.text = "닉네임을 알려주세요"
        $0.textColor = UIColor(3, 7, 18, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 24)
        $0.numberOfLines = 1
    }
    
    let descriptionLabel = UILabel().then {
        $0.text = "루티에서 불릴 닉네임이에요"
        $0.textColor = UIColor(107, 114, 128, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.regular.rawValue, size: 14)
        $0.numberOfLines = 1
    }
    
    let textField = UITextField().then {
        $0.placeholder = "닉네임을 입력해 주세요"
        //$0.borderStyle = .roundedRect
        $0.backgroundColor = UIColor(243, 244, 246, 1)
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 0
        
        $0.autocorrectionType = .no                     // 자동 수정 활성화 여부
        $0.spellCheckingType = .no                      // 맞춤법 검사 활성화 여부
        $0.autocapitalizationType = .none               // 자동 대문자 활성화 여부
        $0.clearButtonMode = .always                    // 입력내용 한번에 지우는 x버튼(오른쪽)
        $0.clearsOnBeginEditing = false                 // 편집 시 기존 텍스트필드값 제거?
        $0.returnKeyType = .done                        // 키보드 엔터키(return, done... )
    }
    
    let nicknameDescription = UILabel().then {
        $0.text = "한글,영어,숫자,이모지,특수문자 포함 최대 20자"
        $0.textColor = UIColor(107, 114, 128, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.regular.rawValue, size: 12)
        $0.numberOfLines = 1
    }
    
    let maxCountLabel = UILabel().then {
        $0.text = "/20"
        $0.textColor = UIColor(107, 114, 128, 1)
        $0.textAlignment = .right
        $0.font = UIFont(name: Font.regular.rawValue, size: 12)
        $0.numberOfLines = 1
    }
    
    let currentCountLabel = UILabel().then {
        $0.text = "0"
        $0.textColor = UIColor(3, 7, 18, 1)
        $0.textAlignment = .right
        $0.font = UIFont(name: Font.regular.rawValue, size: 12)
        $0.numberOfLines = 1
    }
    
    let moveNextPageBtn = UIButton().then {
        $0.backgroundColor = UIColor(31, 41, 55, 1)
        $0.layer.cornerRadius = 16
        $0.setTitle("다음으로", for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.setTitleColor(.white, for: .normal)
    }
    
    // 1 : 문자 하나라도 입력해야함
    // 2 : 닉네임 ok
    // 3 : 최대 글자 수 넘김
    var isNickNameCheckd = 1 {
        didSet {
            if isNickNameCheckd == 1 {
                nicknameDescription.text = "공백만으로는 닉네임을 만들 수 없어요"
                nicknameDescription.textColor = UIColor(107, 114, 128, 1)
                currentCountLabel.textColor = UIColor(3, 7, 18, 1)
            }
            else if isNickNameCheckd == 2 {
                nicknameDescription.text = "닉네임은 1-20자로 입력해 주세요 (공백 제외)"
                nicknameDescription.textColor = UIColor(107, 114, 128, 1)
                currentCountLabel.textColor = UIColor(3, 7, 18, 1)
            }
            else if isNickNameCheckd == 3 {
                nicknameDescription.text = "20자 이내로 입력해주세요"
                nicknameDescription.textColor = UIColor(234, 88, 12, 1)
                currentCountLabel.textColor = UIColor(234, 88, 12, 1)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setTextField()
        setLayout()
        addTarget()
        
        // 프로그래스 바 0 -> 0.5 변화 애니메이션을 위한 초기값
        self.progressBarView.ratio = 0.0
        
        addObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 프로그래스 바 0 -> 0.3 변화 애니메이션
        self.progressBarView.ratio = 0.3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 스와이프 뒤로 가기 제스처 다시 활성화
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    func requestSignUp() {
        let url = NetworkManager.shared.getRequestURL(api: "/api/member/sign")
        let param = JSONModel.SingIn(nickName: textField.text!, isAgree: isAgree)
        print("requestAPI 넣기전 Request Params: \(param)")
        // Encodable을 JSON으로 변환
        guard let jsonData = try? JSONEncoder().encode(param),
              var param = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else { return }
        
        // NSNumber에서 Bool로 변환
        if let number = param["isAgree"] as? NSNumber {
            param["isAgree"] = number.boolValue
        }
        
        NetworkManager.shared.requestAPI(url: url, method: .put, encoding: JSONEncoding.default , param: param) { result in
            
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.SignUpResponse.self, from: data)
                    if decodedResponse.message == "update" {
                        print("다음페이지로 이동")
                        DataManager.shared.userNickName = self.textField.text
                        self.moveToNextPage()
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
    
    func addTarget() {
        var tapGesture = UITapGestureRecognizer(target: self, action: #selector(goBack))
        backBtn.addGestureRecognizer(tapGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapNextPageBtn))
        moveNextPageBtn.addGestureRecognizer(tapGesture)
    }
    
    func addObserver() {
        // 실시간 입력 이벤트 감지
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // 키보드 동작 관련
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 키보드 올라왔을 때 버튼이 키보드 위로 올라오도록 설정
    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        self.moveNextPageBtn.snp.remakeConstraints() {
            $0.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(keyboardFrame.height - self.view.safeAreaInsets.bottom + 20)
            $0.height.equalTo(56)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // 키보드 내려갔을 때 버튼이 기존 자리로 가도록 설정
    @objc func keyboardWillHide(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        self.moveNextPageBtn.snp.remakeConstraints() {
            $0.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(56)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // 현재 텍스트에서 글자 수 계산
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        let characterCount = text.countText()
        currentCountLabel.text = "\(characterCount)"
        
        if characterCount == 0 {
            isNickNameCheckd = 1
        }
        else if characterCount == 20 {
            isNickNameCheckd = 3
        }
        else if characterCount >= 21 {
            // 20자 초과한 글자는 바로 삭제
            textField.deleteBackward()
            print(textField.text)
        }
        else {
            isNickNameCheckd = 2
        }
    }
    
    @objc func tapNextPageBtn() {
        if let text = textField.text, text.first == " " {
            print("첫 입력으로 공백은 불가, 다음페이지로 이동 불가")
        }
        else if isNickNameCheckd == 2 || isNickNameCheckd == 3 {
            requestSignUp()
        }
        else {
            print("다음페이지로 이동 불가")
        }
    }
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func moveToNextPage() {
        let secondVC = OnBoardingMainViewController()
        secondVC.modalPresentationStyle = .fullScreen
        
        navigationController?.pushViewController(secondVC, animated: true)
    }
    
    func setTextField() {
        textField.delegate = self
        textField.addLeftPadding() // textfield 왼쪽에 padding 추가
    }

    func setLayout() {
        [navigationView, backBtn, progressBarView, titleLabel1, titleLabel2, descriptionLabel, textField, nicknameDescription, maxCountLabel, currentCountLabel, moveNextPageBtn].forEach({ view.addSubview($0) })
        [backBtn, progressBarView].forEach({ navigationView.addSubview($0) })
        
        self.navigationView.snp.makeConstraints {
            $0.top.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(24)
        }
        
        self.backBtn.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        self.progressBarView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(40)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(8)
        }
        
        self.titleLabel1.snp.makeConstraints({
            $0.top.equalTo(progressBarView).offset(48)
            $0.leading.trailing.equalToSuperview().inset(20)
        })
        
        self.titleLabel2.snp.makeConstraints({
            $0.top.equalTo(titleLabel1.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
        })
        
        self.descriptionLabel.snp.makeConstraints({
            $0.top.equalTo(titleLabel2.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(20)
        })
        
        self.textField.snp.makeConstraints({
            $0.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(40)
            $0.height.equalTo(48)
        })
        
        self.nicknameDescription.snp.makeConstraints({
            $0.left.equalToSuperview().inset(28)
            $0.top.equalTo(textField.snp.bottom).offset(7)
        })
        
        self.maxCountLabel.snp.makeConstraints({
            $0.right.equalToSuperview().inset(20)
            $0.top.equalTo(textField.snp.bottom).offset(7)
        })
        
        self.currentCountLabel.snp.makeConstraints({
            $0.right.equalTo(maxCountLabel.snp.left)
            $0.top.equalTo(textField.snp.bottom).offset(7)
        })
        
        self.moveNextPageBtn.snp.makeConstraints {
            $0.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(56)
        }
    }
}

extension SignUpWriteNameViewController: UITextFieldDelegate {
    // 키보드 외의 화면 누를 시 키보드 내려감
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // 완료버튼 누를시 키보드 내려감
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // 한글자 입력/제거 할때마다 호출
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // 최대 글자수 도달하더라도 backspace는 허용
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        
        let text = textField.text ?? ""
        let textCount = text.countText()
        
        return true
    }
}

extension SignUpWriteNameViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // 스와이프 제스처 허용
    }
}
