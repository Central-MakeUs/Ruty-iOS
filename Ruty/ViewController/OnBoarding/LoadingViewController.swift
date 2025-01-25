//
//  LoadingViewController.swift
//  Ruty
//
//  Created by 정성희 on 1/24/25.
//

import UIKit

class LoadingViewController: UIViewController {
    
    
    //var descriptionText = DataManager.shared.userNickName ?? "empty"
    let rotatingView = UIView() // 회전할 뷰
    let rotatingBackgroundView = UIView() // 회전할 뷰의 배경
    
    let nicknameLabel = UILabel().then {
        $0.text = DataManager.shared.userNickName ?? "empty"
        $0.textColor = UIColor(28, 27, 31, 1)
        $0.textAlignment = .center
        $0.font = UIFont(name: Font.regular.rawValue, size: 16)
        $0.numberOfLines = 0
    }
    
    let descriptionLabel = UILabel().then {
        $0.text = "목표에 딱 맞는 루틴 찾는중.. 0%"
        $0.textColor = UIColor(28, 27, 31, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.regular.rawValue, size: 16)
        $0.numberOfLines = 0
    }
    
    let percentLabel = UILabel().then {
        $0.text = "0%"
        $0.textColor = UIColor(28, 27, 31, 1)
        $0.textAlignment = .right
        $0.font = UIFont(name: Font.regular.rawValue, size: 16)
        $0.numberOfLines = 0
    }
    
    let textBox = UIView().then {
        $0.backgroundColor = .blue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        nicknameLabel.text! += "님의"
        // 회전할 뷰 설정
        setupRotatingView()
        
        setLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 뷰가 나타난 후 애니메이션 시작
        startRotatingAnimation()
    }
    
    // 로딩 view 구현
    private func setupRotatingView() {
        // 로딩 바의 크기 및 위치 설정
        let size: CGFloat = 72
        rotatingView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        rotatingView.center = CGPoint(x: view.bounds.width / 2, y: 261)
        rotatingView.backgroundColor = .clear
        
        // 원형 경로 생성
        let shapeLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: size / 2, y: size / 2),
                                        radius: size / 2,
                                        startAngle: 0,
                                        endAngle: .pi / 4,
                                        clockwise: true)
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor(99, 102, 241, 1).cgColor
        shapeLayer.fillColor = UIColor(99, 102, 241, 1).cgColor
        shapeLayer.lineWidth = 10                       // 선의 두께
        shapeLayer.lineCap = .round                    // 끝부분을 둥글게
        rotatingView.layer.addSublayer(shapeLayer)
        
        
        // 로딩 바 배경의 크기 및 위치 설정
        rotatingBackgroundView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        rotatingBackgroundView.center = CGPoint(x: view.bounds.width / 2, y: 261)
        rotatingBackgroundView.backgroundColor = .clear
        let shapeLayerBackground = CAShapeLayer()
        let circularPathBackground = UIBezierPath(arcCenter: CGPoint(x: size / 2, y: size / 2),
                                        radius: size / 2,
                                        startAngle: 0,
                                        endAngle: .pi * 2,
                                        clockwise: true)

        shapeLayerBackground.path = circularPathBackground.cgPath
        shapeLayerBackground.strokeColor = UIColor(224, 231, 255, 1).cgColor
        shapeLayerBackground.fillColor = UIColor.clear.cgColor
        shapeLayerBackground.lineWidth = 10
        shapeLayerBackground.lineCap = .round
        rotatingBackgroundView.layer.addSublayer(shapeLayerBackground)
    }
    
    // 로딩 view 무한 애니메이션 설정
    private func startRotatingAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0                      // 시작 각도
        rotationAnimation.toValue = CGFloat.pi * 2           // 끝 각도 (360도)
        rotationAnimation.duration = 1.5                     // 애니메이션 지속 시간
        rotationAnimation.repeatCount = .infinity            // 무한 반복
        rotationAnimation.isRemovedOnCompletion = false      // 애니메이션 중단 후 상태 유지
        
        // 애니메이션 추가
        rotatingView.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func setLayout() {
        [rotatingBackgroundView, rotatingView, nicknameLabel, descriptionLabel].forEach({ self.view.addSubview($0) })
        
        self.nicknameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(rotatingView.snp.bottom).offset(37)
        }
        self.descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(5)
        }
    }
}
