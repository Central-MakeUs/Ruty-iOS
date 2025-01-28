//
//  LoadingView.swift
//  Ruty
//
//  Created by 정성희 on 1/24/25.
//

import Foundation
import UIKit

class LoadingView: UIView {
    private let rotatingLayer = CAShapeLayer()
    private let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // 중심점과 반지름 계산
        let centerPoint = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius: CGFloat = min(bounds.width, bounds.height) / 2 - 10

        // 원호 경로 설정
        let circularPath = UIBezierPath(arcCenter: centerPoint,
                                        radius: radius,
                                        startAngle: CGFloat(-Double.pi / 2),
                                        endAngle: CGFloat(Double.pi * 1.5),
                                        clockwise: true)

        // CAShapeLayer 설정
        rotatingLayer.path = circularPath.cgPath
        rotatingLayer.fillColor = UIColor.clear.cgColor
        rotatingLayer.strokeColor = UIColor.systemBlue.cgColor
        rotatingLayer.lineWidth = 10
        rotatingLayer.lineCap = .round
        rotatingLayer.frame = bounds
        layer.addSublayer(rotatingLayer)

        // 애니메이션 설정
        rotationAnimation.toValue = CGFloat.pi * 2
        rotationAnimation.duration = 1.5
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.isRemovedOnCompletion = false
    }

    func startAnimation() {
        rotatingLayer.add(rotationAnimation, forKey: "rotationAnimation")
    }

    func stopAnimation() {
        rotatingLayer.removeAnimation(forKey: "rotationAnimation")
    }
}
