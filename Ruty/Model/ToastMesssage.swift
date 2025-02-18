//
//  ToastMesssage.swift
//  Ruty
//
//  Created by 정성희 on 1/13/25.
//

import UIKit

func showToast(view : UIView , message : String, imageName: String, withDuration: Double, delay: Double, buttonTitle: String? = nil, buttonAction: (() -> Void)? = nil, nonClickAction: (() -> ())? = nil ) {
    let toastLabel = UILabel().then {
        $0.textColor = UIColor(255, 255, 255, 1)
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.text = message
        $0.textAlignment = .center
    }
    let toastCheckImage = UIImageView().then {
        $0.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        $0.image = UIImage(named: imageName)
    }
    let toastBackground = UIView().then {
        $0.backgroundColor = UIColor(75, 85, 99, 1)
        $0.layer.cornerRadius = 25
    }
    
    let button: UIButton? = {
        guard let title = buttonTitle else { return nil }
        guard let buttonAction = buttonAction else { return nil }
        let btn = UIButton(type: .system).then {
            $0.setTitle(title, for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
            $0.backgroundColor = .clear
            $0.layer.cornerRadius = 12
            $0.addAction(UIAction(handler: { _ in buttonAction() }), for: .touchUpInside)
        }
        return btn
    }()
    
    let underBar = UIView().then {
        $0.backgroundColor = .white
    }
    
    view.addSubview(toastBackground)
    toastBackground.addSubview(toastLabel)
    toastBackground.addSubview(toastCheckImage)
    
    var textWidth: CGFloat?
    if let button = button {
        toastBackground.addSubview(button)
        toastBackground.addSubview(underBar)
    
        textWidth = (buttonTitle as! NSString).size(withAttributes: [.font: UIFont(name: Font.semiBold.rawValue, size: 16)]).width
    }
    
    toastLabel.sizeToFit()
    let labelWidth = toastLabel.frame.size.width
    
    toastBackground.snp.makeConstraints {
        $0.centerX.equalToSuperview()
        $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(96)
        $0.height.equalTo(56)
        $0.width.equalTo(labelWidth + (button == nil ? 77 : 77 + textWidth!)) // 버튼이 있으면 더 넓게 조정
    }
    
    toastCheckImage.snp.makeConstraints {
        $0.centerY.equalToSuperview()
        $0.left.equalToSuperview().inset(20)
        $0.height.width.equalTo(24)
    }
    
    if let button = button {
        toastLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(toastCheckImage.snp.right).offset(8)
            $0.right.equalTo(button.snp.left).offset(-8)
        }
        
        button.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(12)
        }
        
        underBar.snp.makeConstraints {
            $0.top.equalTo(button.snp.bottom).inset(7)
            $0.left.equalTo(button.snp.left).inset(3)
            $0.right.equalTo(button.snp.right).inset(3)
            $0.height.equalTo(1.5)
        }
    } else {
        toastLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(toastCheckImage.snp.right).offset(8)
            $0.right.equalToSuperview().inset(12)
        }
    }
    
    // delay 초 후에 토스트 메시지 삭제
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        UIView.animate(withDuration: withDuration, delay: 0, options: .curveEaseOut, animations: {
            toastBackground.alpha = 0.0
        }, completion: {(isCompleted) in
            toastBackground.removeFromSuperview()
            
            guard let nonClickAction = nonClickAction else { return }
            nonClickAction()
        })
    }
}
