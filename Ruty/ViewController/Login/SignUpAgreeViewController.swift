//
//  SignUpAgreeViewController.swift
//  Ruty
//
//  Created by 정성희 on 1/9/25.
//

import UIKit
import SnapKit
import Then

class SignUpAgreeViewController: UIViewController {

    private let progressBarView = ProgressBarView().then {
        $0.layer.cornerRadius = 4
    }

    let titleLabel = UILabel().then {
        $0.text = """
이용약관에
동의해 주세요
"""
        $0.textColor = UIColor(3, 7, 18, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.SemiBold.rawValue, size: 24)
        $0.numberOfLines = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setLayout()
        self.progressBarView.ratio = 0.0
    }
    

    func setLayout() {
        [progressBarView, titleLabel].forEach({ view.addSubview($0) })
        
        self.progressBarView.snp.makeConstraints {
            $0.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(8)
        }
        
        self.titleLabel.snp.makeConstraints({
            $0.top.equalTo(progressBarView).offset(48)
            $0.leading.trailing.equalToSuperview().inset(20)
        })
    }

}
