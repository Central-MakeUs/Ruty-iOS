//
//  CategoryCollectionViewCell.swift
//  Ruty
//
//  Created by 정성희 on 2/1/25.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "CategoryCollectionViewCell"
    
    let titleLabel = UILabel().then {
        $0.textColor = UIColor(3, 7, 18, 1)
        $0.textAlignment = .center
        $0.font = UIFont(name: Font.medium.rawValue, size: 14)
    }
    
    var isClicked = false {
        didSet {
            if isClicked {
                titleLabel.textColor = UIColor(99, 102, 241, 1)
                titleLabel.font = UIFont(name: Font.semiBold.rawValue, size: 14)
                contentView.backgroundColor = UIColor(245, 248, 255, 1)
                contentView.layer.borderColor = UIColor(129, 140, 248, 1).cgColor
            }
            else {
                titleLabel.textColor = UIColor(3, 7, 18, 1)
                titleLabel.font = UIFont(name: Font.medium.rawValue, size: 14)
                contentView.backgroundColor = .white
                contentView.layer.borderColor = UIColor(229, 231, 235, 1).cgColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(229, 231, 235, 1).cgColor
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContent(category: String) {
        titleLabel.text = category
    }
}
