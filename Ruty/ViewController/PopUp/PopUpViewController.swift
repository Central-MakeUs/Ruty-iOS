//
//  PopUpViewController.swift
//  Ruty
//
//  Created by 정성희 on 2/28/25.
//

import UIKit

class PopUpViewController: UIViewController {
    
    var onCompleted: () -> () = {}
    
//    init(titleString: String = "test", descritipnString: String = "test", cancelBtnText: String = "취소", acceptBtnText: String = "확인") {
//        self.titleString = titleString
//        self.descritipnString = descritipnString
//        self.cancelBtnText = cancelBtnText
//        self.acceptBtnText = acceptBtnText
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
//    var titleString: String
//    var descritipnString: String
//    var cancelBtnText : String
//    var acceptBtnText : String
    
    private let popView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "정말 포기하시겠어요?"
        $0.textColor = UIColor.font.primary
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 20)
        $0.numberOfLines = 0
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "지금 포기하면 기존 기록을 복원할 수 없어요. 정말 포기하시겠어요?"
        $0.textColor = UIColor.font.secondary
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.regular.rawValue, size: 16)
        $0.numberOfLines = 0
    }
    
    private let cancelBtn = UIButton().then {
        $0.setTitle("아니오", for: .normal)
        $0.backgroundColor = UIColor(31, 41, 55, 1)
        $0.layer.cornerRadius = 12
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.addTarget(self, action: #selector(tapCancelBtn), for: .touchUpInside)
    }
    
    private let acceptBtn = UIButton().then {
        $0.setTitle("네, 포기할게요", for: .normal)
        $0.backgroundColor = UIColor(249, 115, 22, 1)
        $0.layer.cornerRadius = 12
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.addTarget(self, action: #selector(tapAcceptBtn), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(0, 0, 0, 0.56)
        setLayout()
        setUI()
    }
    
    @objc func tapCancelBtn() {
        self.dismiss(animated: true)
    }
    
    @objc func tapAcceptBtn() {
        onCompleted()
        self.dismiss(animated: true)
//        let nextVC = LoginViewController()
//        self.view.window?.rootViewController = nextVC
//        self.view.window?.makeKeyAndVisible()
    }
    
    func setUI() {
        // 전체 화면에 탭 제스처 추가
        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        view.addGestureRecognizer(backgroundTapGesture)
    }
    
    // popView 이외의 화면 클릭시 pop 뷰 안보이게하는 함수
    @objc func handleBackgroundTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: view)
        if let popView = view.subviews.first(where: { $0 is UIView && $0.layer.cornerRadius == 16 }) {
            if !popView.frame.contains(tapLocation) {
                self.dismiss(animated: false)
            }
        }
    }
    
//    func setData() {
//        cancelBtn.setTitle(cancelBtnText, for: .normal)
//        acceptBtn.setTitle(acceptBtnText, for: .normal)
//        titleLabel.text = titleString
//        descriptionLabel.text = descritipnString
//    }
    
    func setLayout() {
        [popView].forEach({ self.view.addSubview($0) })
        [titleLabel, descriptionLabel, cancelBtn, acceptBtn].forEach({ popView.addSubview($0) })
        
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
        
        self.cancelBtn.snp.makeConstraints {
            $0.bottom.left.equalToSuperview().inset(20)
            $0.right.equalTo(popView.snp.centerX).offset(-8)
            $0.height.equalTo(48)
        }
        
        self.acceptBtn.snp.makeConstraints {
            $0.bottom.right.equalToSuperview().inset(20)
            $0.left.equalTo(popView.snp.centerX).offset(8)
            $0.height.equalTo(48)
        }
    }
}
