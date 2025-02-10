//
//  MainHomeViewController.swift
//  Ruty
//
//  Created by 정성희 on 2/7/25.
//

import UIKit

class MainHomeViewController: UIViewController {

    private let contentScrollView = UIScrollView().then {
        $0.backgroundColor = UIColor.background.secondary
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = UIColor.background.secondary
    }
    
    private let tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.separatorStyle = .singleLine
        $0.isScrollEnabled = false
    }
    
    private let categoryBoxView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    private let categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 88, height: 88)
        layout.scrollDirection = .horizontal // 가로 스크롤 설정
        layout.minimumLineSpacing = 0       // 셀 간격
        layout.minimumInteritemSpacing = 0  // 아이템 간격

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupCollectionView()
        setupTableView()
        
        setLayout()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none // cell 라인 없애기
        tableView.register(TodayRoutineCell.self, forCellReuseIdentifier: TodayRoutineCell.identifier)
    }
    
    private func setupCollectionView() {
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.register(CategoryLevelCell.self, forCellWithReuseIdentifier: CategoryLevelCell.identifier)
    }
    
    private func setLayout() {
        [contentScrollView].forEach({ view.addSubview($0) })
        [contentView].forEach({ contentScrollView.addSubview($0) })
        [categoryBoxView].forEach({ contentView.addSubview($0) })
        [categoryCollectionView].forEach({ categoryBoxView.addSubview($0) })
        
        self.contentScrollView.snp.makeConstraints {
            $0.top.bottom.right.left.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.contentView.snp.makeConstraints {
            $0.top.bottom.right.left.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(1400)
        }
        
        self.categoryBoxView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(120)
        }
        
        self.categoryCollectionView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            $0.left.equalToSuperview().inset(6)
            $0.right.equalToSuperview().inset(6)
            $0.height.equalTo(120)
        }
    }
    
    private func setUI() {
        view.backgroundColor = UIColor.background.secondary
        // 기본 네비게이션바 비활성화
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension MainHomeViewController : UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodayRoutineCell.identifier, for: indexPath) as? TodayRoutineCell else {
            return UITableViewCell()
        }
//        let item = routinesData[selectedCategoryIndex][indexPath.row]
//        cell.setContent(id: item.id, routineName: item.title, description: item.description, markImage: "housing")
//        
        // cell 클릭시 보이게 되는 회색 배경색 제거
        let background = UIView()
        background.backgroundColor = .clear
        cell.selectedBackgroundView = background
        
        //cell.setupLayout()
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row: \(indexPath.row)")
           
        // 클릭한 cell 에 접근
        if let selectedCell = tableView.cellForRow(at: indexPath) as? RoutineCellTableViewCell {
            //selectedCell.tapCell()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension MainHomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryLevelCell.identifier, for: indexPath) as? CategoryLevelCell else {
            return UICollectionViewCell()
        }
        
        //cell.progress = 0.7
        cell.setContent(category: "MONEY", point: 20)
        return cell
    }

    // 셀 크기 지정
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let text = appearCategory[indexPath.row]
//        let label = UILabel()
//        label.text = text
//        label.font = UIFont(name: Font.medium.rawValue, size: 14)
//        
//        // 패딩 추가
//        let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 40))
//        return CGSize(width: size.width + 40, height: 38)
//    }
}
