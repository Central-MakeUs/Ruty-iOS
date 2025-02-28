//
//  PopUpViewController.swift
//  Ruty
//
//  Created by 정성희 on 2/28/25.
//

import UIKit

class PopUpViewController: UIViewController {
    
    private let popView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "로그인"
        $0.textColor = UIColor.font.primary
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 20)
        $0.numberOfLines = 0
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "로그인 한 후에 이용가능합니다"
        $0.textColor = UIColor.font.secondary
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.regular.rawValue, size: 16)
        $0.numberOfLines = 0
    }
    
    private let cancelBtn = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.backgroundColor = UIColor.fill.secondary
        $0.layer.cornerRadius = 12
        $0.setTitleColor(UIColor.font.primary, for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.addTarget(self, action: #selector(tapCancelBtn), for: .touchUpInside)
    }
    
    private let loginBtn = UIButton().then {
        $0.setTitle("로그인하기", for: .normal)
        $0.backgroundColor = UIColor.fill.brand
        $0.layer.cornerRadius = 12
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.addTarget(self, action: #selector(tapLoginBtn), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(0, 0, 0, 0.56)
        setLayout()
    }
    
    @objc func tapCancelBtn() {
        self.dismiss(animated: true)
    }
    
    @objc func tapLoginBtn() {
        let nextVC = LoginViewController()
        self.view.window?.rootViewController = nextVC
        self.view.window?.makeKeyAndVisible()
    }
    
    func setLayout() {
        [popView].forEach({ self.view.addSubview($0) })
        [titleLabel, descriptionLabel, cancelBtn, loginBtn].forEach({ popView.addSubview($0) })
        
        self.popView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.left.equalToSuperview().inset(32)
            $0.height.equalTo(178)
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.right.left.equalToSuperview().inset(20)
        }
        
        self.descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.right.left.equalToSuperview().inset(20)
        }
        
        self.cancelBtn.snp.makeConstraints {
            $0.bottom.left.equalToSuperview().inset(20)
            $0.right.equalTo(popView.snp.centerX).offset(-8)
            $0.height.equalTo(48)
        }
        
        self.loginBtn.snp.makeConstraints {
            $0.bottom.right.equalToSuperview().inset(20)
            $0.left.equalTo(popView.snp.centerX).offset(8)
            $0.height.equalTo(48)
        }
    }
}
