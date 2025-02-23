//
//  ErrorViewController.swift
//  Ruty
//
//  Created by 정성희 on 2/19/25.
//

import UIKit

class ErrorViewController: UIViewController {

    
    private let errorLabel = UILabel().then {
        $0.text = "오류가 발생했어요 다시시도해주세요 :-("
        $0.textColor = UIColor(28, 27, 31, 1)
        $0.textAlignment = .center
        $0.font = UIFont(name: Font.regular.rawValue, size: 16)
        $0.numberOfLines = 0
    }
    
    private let tryAgainView = UIView().then {
        $0.backgroundColor = UIColor.fill.primary
        $0.layer.cornerRadius = 12
        $0.isUserInteractionEnabled = true
    }
    
    private let tryAgainLabel = UILabel().then {
        $0.text = "다시시도"
        $0.textColor = .white
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.numberOfLines = 0
    }
    
    private let tryAgainIcon = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "Icon-Refresh")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setLayout()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goBackPage))
        tryAgainView.addGestureRecognizer(tapGesture)
    }

    private func setLayout() {
        [errorLabel, tryAgainView].forEach({ view.addSubview($0) })
        [tryAgainLabel, tryAgainIcon].forEach({ tryAgainView.addSubview($0) })
        
        self.errorLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-20)
        }
        
        self.tryAgainView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(20)
            $0.height.equalTo(48)
            $0.width.equalTo(116)
        }
        
        self.tryAgainLabel.snp.makeConstraints {
            $0.right.equalTo(tryAgainView.snp.right).inset(16)
            $0.centerY.equalToSuperview()
        }
        
        self.tryAgainIcon.snp.makeConstraints {
            $0.left.equalTo(tryAgainView.snp.left).inset(16)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(16)
        }
    }
    
    @objc func goBackPage() {
        self.dismiss(animated: true)
    }
    
    static func showErrorPage(viewController: UIViewController) {
        let errorVC = ErrorViewController()
        errorVC.modalPresentationStyle = .fullScreen
        viewController.present(errorVC, animated: true, completion: nil)
    }
}
