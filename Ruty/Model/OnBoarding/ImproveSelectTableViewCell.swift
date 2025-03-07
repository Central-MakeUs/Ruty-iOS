//
//  ImproveSelectTableViewCell.swift
//  Ruty
//
//  Created by 정성희 on 1/23/25.
//

import UIKit

class ImproveSelectTableViewCell: UITableViewCell {
    
    static let identifier = "ImproveSelectTableViewCell"
    
    let cellBlock = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(229, 231, 235, 1).cgColor
        $0.layer.cornerRadius = 16
    }
    
    let content = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .black
        $0.backgroundColor = .clear
    }
    
    let image = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "housing")
    }
    
    let checkImage = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "checkOff")
    }
    
    var isChecked = false {
        didSet {
            if isChecked == true {
                checkImage.image = UIImage(named: "checkOn")
                cellBlock.backgroundColor = UIColor(245, 248, 255, 1)
                cellBlock.layer.borderColor = UIColor(129, 140, 248, 1).cgColor
            }
            else {
                checkImage.image = UIImage(named: "checkOff")
                cellBlock.backgroundColor = .white
                cellBlock.layer.borderColor = UIColor(229, 231, 235, 1).cgColor
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        [cellBlock].forEach({ contentView.addSubview($0) })
        [image, content, checkImage].forEach({ cellBlock.addSubview($0) })
        
        cellBlock.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(64)
            $0.bottom.equalToSuperview().inset(16)
            $0.top.equalToSuperview()
        }
        
        image.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(20)
            $0.height.width.equalTo(24)
        }
        
        content.snp.makeConstraints {
            $0.left.equalTo(image.snp.right).offset(8)
            $0.centerY.equalToSuperview()
        }
        
        checkImage.snp.makeConstraints {
            $0.right.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }
    
    func setContent(text: String, category: String) {
        content.text = text
        image.image = UIImage(named: RoutineCategoryImage.shared[category] ?? "housing")
    }
    
    func tapCell() {
        isChecked = !isChecked
    }
}
