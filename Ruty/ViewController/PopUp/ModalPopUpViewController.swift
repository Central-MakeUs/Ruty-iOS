//
//  ModalPopUpViewController.swift
//  Ruty
//
//  Created by 정성희 on 2/28/25.
//

import UIKit

class ModalPopUpViewController: UIViewController {

    var level = 1
    var category = "test"
    
    private let popView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
    }
    
    private let titleLabel = UILabel().then {
        $0.text = ""
        $0.textColor = UIColor.font.primary
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 20)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byCharWrapping
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = ""
        $0.textColor = UIColor.font.secondary
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.regular.rawValue, size: 16)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byCharWrapping
    }
    
    private let completeBtn = UIButton().then {
        $0.setTitle("확인", for: .normal)
        $0.backgroundColor = UIColor.fill.secondary
        $0.layer.cornerRadius = 12
        $0.setTitleColor(UIColor.font.primary, for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.addTarget(self, action: #selector(tapCompleteBtn), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(0, 0, 0, 0.56)
        setLayout()
        setValue()
    }
    
    @objc func tapCompleteBtn() {
        self.dismiss(animated: true)
    }
    
    func setValue() {
        let category = categoryUIString[category]!
        titleLabel.text = "\(category) Lv.\(level) 달성"
        descriptionLabel.text = "벌써 Lv.\(level) 라니 멋져요! 다음 레벨까지 달려봐요!"
    }
    
    func setLayout() {
        [popView].forEach({ self.view.addSubview($0) })
        [titleLabel, descriptionLabel, completeBtn].forEach({ popView.addSubview($0) })
        
        self.popView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.left.equalToSuperview().inset(32)
            $0.height.equalTo(202)
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.right.left.equalToSuperview().inset(20)
        }
        
        self.descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.right.left.equalToSuperview().inset(20)
        }
        
        self.completeBtn.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
    }
}
