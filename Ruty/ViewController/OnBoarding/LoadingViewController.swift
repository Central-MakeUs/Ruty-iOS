//
//  LoadingViewController.swift
//  Ruty
//
//  Created by 정성희 on 1/24/25.
//

import UIKit

class LoadingViewController: UIViewController {

    var descriptionText = DataManager.shared.userNickName ?? "empty"
    
    
    let nicknameLabel = UILabel().then {
        $0.text = DataManager.shared.userNickName ?? "empty"
        $0.textColor = UIColor(28, 27, 31, 1)
        $0.textAlignment = .center
        $0.font = UIFont(name: Font.regular.rawValue, size: 16)
        $0.numberOfLines = 0
    }
    
    let descriptionLabel = UILabel().then {
        $0.text = """
님의
목표에 딱 맞는 루틴 찾는중..
"""
        $0.textColor = UIColor(28, 27, 31, 1)
        $0.textAlignment = .center
        $0.font = UIFont(name: Font.regular.rawValue, size: 16)
        $0.numberOfLines = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        descriptionText += """
님의
목표에 딱 맞는 루틴 찾는중..
"""
        print(descriptionText)
        setLayout()
    }
    
    func setLayout() {
        [nicknameLabel].forEach({ self.view.addSubview($0) })
        
        self.nicknameLabel.snp.makeConstraints {
            $0.top.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.centerY.centerX.equalToSuperview()
        }
    }

}
