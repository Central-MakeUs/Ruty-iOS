//
//  RoutineInfoViewController.swift
//  Ruty
//
//  Created by 정성희 on 3/4/25.
//

import UIKit

class RoutineInfoViewController: UIViewController {

    private let contentScrollView = UIScrollView().then {
        $0.backgroundColor = UIColor.background.secondary
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = UIColor.background.secondary
    }
    
    private let backBtn = UIButton().then {
        $0.setImage(UIImage(named: "back"), for: .normal)
        $0.addTarget(self, action: #selector(moveToBackPage), for: .touchUpInside)
    }
    
    private let titleStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .equalCentering
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "퇴근 후 나를 위한 한 끼 만들기"
        $0.textColor = UIColor(23, 23, 25, 1)
        $0.textAlignment = .center
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 20)
        $0.numberOfLines = 0
    }
    
    private let categoryMarkImage = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "housing")
    }
    
    private let dayStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
        $0.distribution = .equalCentering
    }
    
    private let dayLabel = UILabel().then {
        $0.text = "월, 화, 수, 목, 금, 일"
        $0.textAlignment = .center
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 12)
        $0.textColor = UIColor.font.secondary
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    private let dateLabel = UILabel().then {
        $0.text = "yyyy.MM.dd - yyyy.MM.dd"
        $0.textAlignment = .center
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 12)
        $0.textColor = UIColor.font.secondary
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    private let processRateBlock = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    private let processRateLabel = UILabel().then {
        $0.text = "달성률"
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.medium.rawValue, size: 14)
        $0.textColor = UIColor.font.secondary
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    private let processPercent = UILabel().then {
        $0.text = "N%"
        $0.textAlignment = .right
        $0.font = UIFont(name: Font.medium.rawValue, size: 14)
        $0.textColor = UIColor.font.secondary
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    private let progressBarView = ProgressBarView().then {
        $0.layer.cornerRadius = 4
    }
    
    private let processMarkImage = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "Icon-Circle-Check")
    }
    
    private let processHelperLabel = UILabel().then {
        $0.text = "연속 10회 수행 중!"
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 14)
        $0.textColor = UIColor(23, 23, 25, 1)
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setLayout()
        setProcessBar()
    }
    
    // MARK: - layout, ui
    func setProcessBar() {
        self.progressBarView.ratio = 0.0
    }
    
    func setUI() {
        view.backgroundColor = UIColor.background.secondary
    }
    
    func setLayout() {
        [contentScrollView].forEach({ view.addSubview($0) })
        [contentView].forEach({ contentScrollView.addSubview($0) })
        [backBtn, titleStack, dayStack, processRateBlock].forEach({ contentView.addSubview($0) })
        
        [categoryMarkImage, titleLabel].forEach({ titleStack.addArrangedSubview($0) })
        [dayLabel, dateLabel].forEach({ dayStack.addArrangedSubview($0) })
        [processRateLabel, processPercent, progressBarView, processMarkImage, processHelperLabel].forEach({ processRateBlock.addSubview($0) })
        
        self.contentScrollView.snp.makeConstraints {
            $0.top.bottom.right.left.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.contentView.snp.makeConstraints {
            $0.top.bottom.right.left.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(1000)
        }
        
        self.backBtn.snp.makeConstraints {
            $0.top.left.equalToSuperview().inset(20)
            $0.height.width.equalTo(24)
        }
        
        self.titleStack.snp.makeConstraints {
            $0.top.equalTo(backBtn.snp.bottom).offset(52)
            $0.centerX.equalToSuperview()
            //$0.left.right.equalToSuperview().inset(20)
        }
        
        self.categoryMarkImage.snp.makeConstraints({
            $0.width.height.equalTo(24)
        })
        
        self.dayStack.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            //$0.left.right.equalToSuperview().inset(20)
        }
        
        self.processRateBlock.snp.makeConstraints {
            $0.top.equalTo(dayStack.snp.bottom).offset(52)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(110)
        }
        
        self.processRateLabel.snp.makeConstraints {
            $0.top.left.equalToSuperview().inset(16)
        }
        
        self.processPercent.snp.makeConstraints {
            $0.top.right.equalToSuperview().inset(16)
        }
        
        self.progressBarView.snp.makeConstraints {
            $0.top.equalTo(processRateLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(8)
        }
        
        self.processMarkImage.snp.makeConstraints {
            $0.left.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(18)
            $0.height.width.equalTo(20)
        }
        
        self.processHelperLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(19)
            $0.left.equalTo(processMarkImage.snp.right).offset(8)
        }
    }
    
    @objc func moveToBackPage() {
        navigationController?.popViewController(animated: true)
    }

    
    
}
