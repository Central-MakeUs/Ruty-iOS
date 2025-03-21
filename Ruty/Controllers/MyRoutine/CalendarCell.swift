//
//  CalendarCell.swift
//  Ruty
//
//  Created by 정성희 on 3/4/25.
//

import UIKit
import FSCalendar

class CalendarCell: FSCalendarCell {
    
    var day: Int?
    
    private let cellBlock = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
    }
    
    private let dateLabel = UILabel().then {
        $0.text = "-"
        $0.textAlignment = .center
        $0.font = UIFont(name: Font.medium.rawValue, size: 14)
        $0.textColor = UIColor.font.primary
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // 셀이 화면에 표시될 때마다 불리는 메서드 (상태, 선택, 오늘 등)
    override func configureAppearance() {
        super.configureAppearance()
        
        // 기본 FSCalendarCell의 titleLabel, subtitleLabel, shapeLayer를 숨김
        self.titleLabel.isHidden = true
        self.subtitleLabel?.isHidden = true
        self.shapeLayer.isHidden = true
        
        if self.monthPosition != .current {
            setOpacity()
        } else {
            resetOpacity()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetOpacity()
        cellBlock.backgroundColor = .white
        dateLabel.textColor = UIColor.font.primary
    }
    
    // 0: 루틴을 수행함
    // 1: 루틴을 수행하지 않았으나 오늘~미래에 수행가능한 루틴
    // 2: 루틴을 수행하지 않아 실패처리
    func setBackgroundColor(progress: Int) {
        if progress == 0 {
            cellBlock.backgroundColor = UIColor.fill.brand
            dateLabel.textColor = .white
        }
        else if progress == 1 {
            cellBlock.backgroundColor = UIColor(245, 248, 255, 1)
            dateLabel.textColor = UIColor(99, 102, 241, 1)
        }
        else {
            cellBlock.backgroundColor = UIColor(249, 115, 22, 1)
            dateLabel.textColor = .white
        }
    }
    
    func resetOpacity() {
        cellBlock.layer.opacity = 1.0
    }
    
    func setOpacity() {
        cellBlock.layer.opacity = 0.3
    }
    
    func setLayout() {
        [cellBlock].forEach({ contentView.addSubview($0) })
        [dateLabel].forEach({ cellBlock.addSubview($0) })
        
        cellBlock.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(6.5)
            $0.top.bottom.equalToSuperview().inset(6.5)
        }
        
        dateLabel.text = String(day!)
        dateLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
