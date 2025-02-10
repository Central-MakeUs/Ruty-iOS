//
//  CategoryLevelCell.swift
//  Ruty
//
//  Created by 정성희 on 2/7/25.
//

import UIKit

class CategoryLevelCell: UICollectionViewCell {
    
    static let identifier = "CategoryLevelCell"
    
    private let gaugeView = UIView().then {
        $0.backgroundColor = .white
    }
    private let backgroundLayer = CAShapeLayer()
    private let fillLayer = CAShapeLayer()
    var progress: CGFloat = 0.5 {
        didSet {
            updateFillLayer()
        }
    }
    
    private let cellBlock = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let levelLabel = UILabel().then {
        $0.text = "Lv.1"
        $0.textColor = UIColor.font.secondary
        $0.textAlignment = .center
        $0.font = UIFont(name: Font.medium.rawValue, size: 14)
        $0.numberOfLines = 1
    }
    
    private let categoryBox = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let categoryIcon = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "housing")
    }
    
    private let categoryLabel = UILabel().then {
        $0.text = "test"
        $0.textColor = UIColor(0, 0, 0, 1)
        $0.textAlignment = .center
        $0.font = UIFont(name: Font.medium.rawValue, size: 14)
        $0.numberOfLines = 1
    }
    
    private func setLayout() {
        [cellBlock].forEach({ contentView.addSubview($0) })
        [gaugeView, levelLabel, categoryBox].forEach({ cellBlock.addSubview($0) })
        [categoryIcon, categoryLabel].forEach({ categoryBox.addSubview($0) })
        
        cellBlock.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview()
            $0.right.equalToSuperview()
            //$0.height.equalTo(100)
            $0.width.equalTo(88)
        }
        
        gaugeView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.width.equalTo(60)
        }
        
        levelLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.centerX.equalToSuperview()
        }
        
        categoryBox.snp.makeConstraints {
            $0.top.equalTo(gaugeView.snp.bottom).offset(8)
            //$0.right.left.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        categoryIcon.snp.makeConstraints {
            $0.top.bottom.left.equalToSuperview()
            $0.height.width.equalTo(20)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.left.equalTo(categoryIcon.snp.right).offset(2)
            $0.right.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    private func setupLayers() {
        let circlePath = UIBezierPath(ovalIn: gaugeView.bounds)
        
        // 배경 원 설정
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.fillColor = UIColor.RoutineCategoryColor.background.cgColor
        gaugeView.layer.addSublayer(backgroundLayer)
        
        // 채우기 원 설정
        fillLayer.path = circlePath.cgPath
        fillLayer.fillColor = UIColor.RoutineCategoryColor.house.cgColor
        fillLayer.mask = createMaskLayer()
        gaugeView.layer.addSublayer(fillLayer)
    }
    
    private func createMaskLayer() -> CALayer {
        let maskLayer = CALayer()
        maskLayer.frame = gaugeView.bounds
        let fillRect = CGRect(x: 0, y: gaugeView.bounds.height * (1 - progress),
                              width: gaugeView.bounds.width, height: gaugeView.bounds.height * progress)
        let fillShape = CALayer()
        fillShape.frame = fillRect
        fillShape.backgroundColor = UIColor.black.cgColor
        
        maskLayer.addSublayer(fillShape)
        return maskLayer
    }
    
    private func updateFillLayer() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        fillLayer.mask = createMaskLayer()
        CATransaction.commit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            self.setupLayers()  // 여기서 호출하여 bounds 확정 후 적용
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContent(category: String, point: Int) {
        switch category {
        case "HOUSE":
            categoryIcon.image = UIImage(named: "housing")
            categoryLabel.text = "주거"
        case "MONEY":
            categoryIcon.image = UIImage(named: "money-icon")
            categoryLabel.text = "소비"
        case "LEISURE":
            categoryIcon.image = UIImage(named: "leisure-icon")
            categoryLabel.text = "여가생활"
        case "SELFCARE":
            categoryIcon.image = UIImage(named: "selfCare-icon")
            categoryLabel.text = "자기관리"
        default: break
        }
        
        let levelAndPercent = getLevelAndPercent(level: 1 , point: point, sumPoint: 0)
        let level = levelAndPercent.0
        let pointPercent = levelAndPercent.1
        
        print("level : \(level)")
        print("pointPercent : \(pointPercent)")
        
        levelLabel.text = String("Lv.\(level)")
        progress = CGFloat(pointPercent)
    }
    
    // 레벨
    func getLevelAndPercent(level: Int , point: Int, sumPoint: Int) -> (Int, Float) {
        var pointForLevelUp = (level - 1) * 15 // 15점
        var rangeStartPoint = sumPoint // 5점
        var rangeEndPoint = rangeStartPoint + pointForLevelUp // 20점
        
        if level == 1 {
            pointForLevelUp = 5
            rangeStartPoint = 0
            rangeEndPoint = 5
        }
        
        if rangeStartPoint <= point && point < rangeEndPoint {
            let pointOfLevel = point - rangeStartPoint
            let percentOfLevelUp = Float(pointOfLevel) / Float(pointForLevelUp) // 11 / 30
            return (level, percentOfLevelUp)
        }
        return getLevelAndPercent(level: level + 1, point: point, sumPoint: rangeEndPoint)
    }
}
