//
//  SignUpWriteNameViewController.swift
//  Ruty
//
//  Created by 정성희 on 1/13/25.
//

import UIKit

class SignUpWriteNameViewController: UIViewController {

    private let progressBarView = ProgressBarView().then {
        $0.layer.cornerRadius = 4
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
        $0.borderStyle = .roundedRect
        $0.backgroundColor = UIColor(243, 244, 246, 1)
        $0.layer.cornerRadius = 16
        
        $0.autocorrectionType = .no                     // 자동 수정 활성화 여부
        $0.spellCheckingType = .no                      // 맞춤법 검사 활성화 여부
        $0.autocapitalizationType = .none               // 자동 대문자 활성화 여부
        $0.clearButtonMode = .always                    // 입력내용 한번에 지우는 x버튼(오른쪽)
        $0.clearsOnBeginEditing = false                 // 편집 시 기존 텍스트필드값 제거?
        $0.returnKeyType = .done                        // 키보드 엔터키(return, done... )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Safe Area Insets: \(self.view.safeAreaInsets)")
        self.view.backgroundColor = .white
        
        setLayout()
        
        // 프로그래스 바 0 -> 0.5 변화 애니메이션을 위한 초기값
        self.progressBarView.ratio = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 프로그래스 바 0 -> 0.5 변화 애니메이션
        self.progressBarView.ratio = 0.5
        
        
    }
    
    func setTextField() {
        textField.delegate = self
        textField.addLeftPadding() // textfield 왼쪽에 padding 추가
    }

    func setLayout() {
        [progressBarView, titleLabel1, titleLabel2, descriptionLabel, textField].forEach({ view.addSubview($0) })
        
        self.progressBarView.snp.makeConstraints {
            $0.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(24)
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
    }
}

extension SignUpWriteNameViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension UITextField {
    func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}
