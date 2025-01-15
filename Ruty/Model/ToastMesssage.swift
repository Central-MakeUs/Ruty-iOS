//
//  ToastMesssage.swift
//  Ruty
//
//  Created by 정성희 on 1/13/25.
//

import UIKit

func showToast(view : UIView , _ message : String, withDuration: Double, delay: Double) {
    let toastLabel = UILabel().then {
        $0.textColor = UIColor(255, 255, 255, 1)
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.text = message
        $0.textAlignment = .center
    }
    let toastCheckImage = UIImageView().then {
        $0.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        $0.image = UIImage(named: "warning-mark")
    }
    let toastBackground = UIView().then {
        $0.backgroundColor = UIColor(75, 85, 99, 1)
        $0.layer.cornerRadius = 25
    }
    
    view.addSubview(toastBackground)
    toastBackground.addSubview(toastLabel)
    toastBackground.addSubview(toastCheckImage)
    
    toastLabel.sizeToFit()
    let labelWidth = toastLabel.frame.size.width
    
    toastBackground.snp.makeConstraints {
        $0.centerX.equalToSuperview()
        $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(96)
        $0.height.equalTo(56)
        $0.width.equalTo(labelWidth + 77) // label 이외의 고정된 크기 값을 77로 지정
    }
    
    toastCheckImage.snp.makeConstraints {
        $0.centerY.equalToSuperview()
        $0.left.equalToSuperview().inset(20)
        $0.height.width.equalTo(24)
    }
    
    toastLabel.snp.makeConstraints {
        $0.centerY.equalToSuperview()
        $0.left.equalTo(toastCheckImage.snp.right).offset(8)
    }

    
    UIView.animate(withDuration: withDuration, delay: delay, options: .curveEaseOut, animations: {
        toastBackground.alpha = 0.0
    }, completion: {(isCompleted) in
        toastBackground.removeFromSuperview()
    })
}
