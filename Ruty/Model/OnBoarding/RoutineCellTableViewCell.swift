//
//  RoutineCellTableViewCell.swift
//  Ruty
//
//  Created by 정성희 on 1/29/25.
//

import UIKit

class RoutineCellTableViewCell: UITableViewCell {

    static let identifier = "RoutineCellTableViewCell"
    
    private let cellBlock = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(229, 231, 235, 1).cgColor
        $0.layer.cornerRadius = 16
    }
    
    private let routineLabel = UILabel().then {
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 20)
        $0.textColor = UIColor(23, 23, 25, 1)
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    private let markImage = UIImageView().then {
        $0.backgroundColor = .clear
        //$0.image = UIImage(named: "housing")
    }
    
    let descripton = UILabel().then {
        $0.font = UIFont(name: Font.regular.rawValue, size: 14)
        $0.textColor = UIColor(28, 27, 31, 1)
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    private let addRoutineBtnView = UIView().then {
        $0.backgroundColor = UIColor(99, 102, 241, 1)
        $0.layer.cornerRadius = 12
    }
    
    private let addRoutineBtnLabel = UILabel().then {
        $0.text = "루틴 담기"
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.textColor = .white
        $0.backgroundColor = .clear
    }
    
    private let addRoutineBtnMark = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "Icon-Plus")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCellBlockHeight() {
        //invalidateIntrinsicContentSize()
        routineLabel.sizeToFit()
        descripton.sizeToFit()
        let fitedHeight = routineLabel.frame.size.height + descripton.frame.size.height
        print("fitedHeight \(fitedHeight)")
        print("text: \(routineLabel.text)")
        cellBlock.snp.updateConstraints {
            $0.height.equalTo(fitedHeight + 128) // 추천 내용 길이에 따라 동적으로 변화
        }
        
    }
    
    func updateCellBlockHeight(row: Int) {
        print("row: \(row)")
        let newHeight = row * 100
        cellBlock.snp.updateConstraints {
            $0.height.equalTo(newHeight + 128) // 추천 내용 길이에 따라 동적으로 변화
        }
    }
    
    func setupLayout() {
        [cellBlock].forEach({ contentView.addSubview($0) })
        [routineLabel, markImage, descripton, addRoutineBtnView].forEach({ cellBlock.addSubview($0) })
        [addRoutineBtnMark, addRoutineBtnLabel].forEach({ addRoutineBtnView.addSubview($0) })
        
        cellBlock.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview().inset(20)
            $0.top.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        markImage.snp.makeConstraints {
            $0.left.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(22)
            $0.height.width.equalTo(24)
        }
        
        routineLabel.snp.makeConstraints {
            $0.left.equalTo(markImage.snp.right).offset(8)
            $0.top.right.equalToSuperview().inset(20)
        }
        
        descripton.snp.makeConstraints {
            $0.top.equalTo(routineLabel.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        addRoutineBtnView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        addRoutineBtnMark.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().inset(103.5)
            $0.height.width.equalTo(16)
        }
        
        addRoutineBtnLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(addRoutineBtnMark.snp.right).offset(12)
        }
    }
    
    func setContent(routineName: String, description: String, markImage: String) {
        self.routineLabel.text = routineName
        self.descripton.text = description
        self.markImage.image = UIImage(named: markImage)
    }
//    
//    func tapCell() {
//        isChecked = !isChecked
//    }

}
