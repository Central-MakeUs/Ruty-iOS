//
//  ProgressBarView.swift
//  Ruty
//
//  Created by 정성희 on 1/10/25.
//

import UIKit

final class ProgressBarView: UIView {
    
    private let progressBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 99, green: 102, blue: 241)
        view.layer.cornerRadius = 4
        return view
    }()
    
    var ratio: CGFloat = 0.0 {
        didSet {
            self.isHidden = !self.ratio.isLess(than: 1.0)
            
            self.progressBarView.snp.remakeConstraints {
                $0.top.bottom.equalTo(self.safeAreaLayoutGuide)
                $0.width.equalToSuperview().multipliedBy(self.ratio)
            }
            
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                options: .curveEaseInOut, // In과 Out 부분을 천천히하라는 의미 (나머지인 중간 부분은 빠르게 진행)
                animations: self.layoutIfNeeded, // autolayout에 애니메이션을 적용시키고 싶은 경우 사용
                completion: nil
            )
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.backgroundColor = UIColor(red: 237, green: 238, blue: 239)
        self.addSubview(self.progressBarView)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}
