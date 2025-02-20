//
//  LoadingViewController.swift
//  Ruty
//
//  Created by 정성희 on 1/24/25.
//

import UIKit

class LoadingViewController: UIViewController {
    
    let rotatingView = UIView() // 회전할 뷰
    let rotatingBackgroundView = UIView() // 회전할 뷰의 배경
    
    var shapeLayer = CAShapeLayer()
    let size: CGFloat = 72
    
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
        setLayout()
        
        // 로딩 뷰 설정
        setupRotatingView()
        
        // ai 데이터 생성 대기 시작
        tryLoadAIData(tryCount: 1)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 스와이프 뒤로 가기 제스처 비활성화
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // 오토레이아웃의 모든 제약 조건을 계산하고 뷰의 크기와 위치를 확정한 후 호출 되는 함수
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setRotatingViewRoutine()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 뷰가 나타난 후 애니메이션 시작
        startRotatingAnimation()
    }
    
    // 최대 3회까지 ai 데이터 요청
    func tryLoadAIData(tryCount: Int) {
        RoutineDataProvider.shared.startloadAIData { isLoad in
            if isLoad {
                DispatchQueue.main.async {
                    // 생성 완료되면 다음 페이지로 이동
                    let secondVC = RoutineViewController()
                    secondVC.modalPresentationStyle = .fullScreen
                    self.navigationController?.setViewControllers([secondVC], animated: true)
                }
            }
            // 로드 실패시 3회까지 재시도
            else if tryCount <= 3 {
                self.tryLoadAIData(tryCount: tryCount + 1)
            }
            // 4회 부터는 에러로 처리하고 로드 시도 중단
            else {
                print("tryCount:\(tryCount) 로드 실패")
            }
        }
    }
    
    // 로딩 view 구현
    private func setupRotatingView() {
        // 로딩 바의 위치 설정
        rotatingView.layer.addSublayer(shapeLayer)
        rotatingView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5) // 중심점 고정
        
        // 로딩 바 배경의 크기 및 위치 설정
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
    
    // 로딩뷰(움직이는 로딩 뷰) 경로 설정
    // 오토레이아웃이 모두 설정되고 나서 로딩 뷰의 경로를 정해줘야 정확한 위치 경로를 나타낼 수 있음
    private func setRotatingViewRoutine() {
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: size / 2, y: size / 2), // 중심점 계산
            radius: size / 2,               // 반지름 계산
            startAngle: 0,
            endAngle: .pi / 2,
            clockwise: true
        )
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor(99, 102, 241, 1).cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor//UIColor(99, 102, 241, 1).cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.lineCap = .round
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
        
        self.rotatingView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(261)
            $0.height.width.equalTo(72)
        }
        
        self.rotatingBackgroundView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(261)
            $0.height.width.equalTo(72)
        }
        
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

extension LoadingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false // 스와이프 제스처 비활성화
    }
}
