//
//  MainHomeViewController.swift
//  Ruty
//
//  Created by 정성희 on 2/7/25.
//

import UIKit
import Alamofire

class MainHomeViewController: UIViewController {
    
    private let topBackgroundView = UIView().then {
        $0.backgroundColor = UIColor.background.secondary
    }
    
    private let bottomBackgroundView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let contentScrollView = UIScrollView().then {
        $0.backgroundColor = .clear//UIColor.background.secondary
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = UIColor.background.secondary
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
    
    private let tableViewTopView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    }
    
    private let tableViewTopLabel = UILabel().then {
        $0.text = "오늘의 루틴"
        $0.textColor = UIColor.font.primary
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 24)
        $0.numberOfLines = 1
    }
    
    private let tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.separatorStyle = .singleLine
        $0.isScrollEnabled = false
    }
    
    private let recommendRoutineBtn = UIButton().then {
        $0.backgroundColor = UIColor.fill.secondary
        $0.layer.cornerRadius = 12
        $0.setTitle("추천 루틴", for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.setTitleColor(UIColor.font.primary, for: .normal)
        $0.addTarget(self, action: #selector(tapRecommendRoutineBtn), for: .touchUpInside)
    }
    
    
    
    private var todayRoutineData = JSONModel.TodayRoutine(message: "", data: []) // 모든 오늘의 루틴 데이터
    private var sortedTodayRoutineData = [[JSONModel.Routine]](repeating: [JSONModel.Routine](), count: 4) // 카테고리별 정렬 & 완료된 루틴은 삭제된 루틴 데이터
    private var showTodayRoutineData = [JSONModel.Routine]() // 사용자에게 보여질 루트 데이터
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setUI()
        setupCollectionView()
        setupTableView()
        
        setLayout()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("view did layout subviews")
        self.updateContentViewHeight()
    }
    
    // MARK: - api 요청
    func loadData() {
        let url = NetworkManager.shared.getRequestURL(api: "/api/routine/today")
        NetworkManager.shared.requestAPI(url: url, method: .get, encoding: URLEncoding.default, param: nil) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.TodayRoutine.self, from: data)
                    self.todayRoutineData = decodedResponse
                    print("todayRoutineData: \(self.todayRoutineData)")
                    
                    self.sortTodayRoutineData()
                    self.makeInnvisibleDoneRutine()
                    self.makeShowTodayRoutine()
                    
                    self.tableView.reloadData()
                } catch {
                    print("JSON 디코딩 오류: \(error)")
                }
                
            case .failure(let error):
                // 요청이 실패한 경우
                print("API 요청 실패: \(error.localizedDescription)")
            }
        }
    }
     
    // 루틴 카테고리별로 정렬
    private func sortTodayRoutineData() {
        for item in todayRoutineData.data {
            switch item.category {
            case "HOUSE" : sortedTodayRoutineData[0].append(item)
            case "MONEY" : sortedTodayRoutineData[1].append(item)
            case "LEISURE" : sortedTodayRoutineData[2].append(item)
            case "SELFCARE" : sortedTodayRoutineData[3].append(item)
            default: break
            }
        }
    }
    
    // 완료된 루틴은 오늘의 루틴 목록에서 제거
    private func makeInnvisibleDoneRutine() {
        for category in 0..<sortedTodayRoutineData.count {
            for (index,item) in sortedTodayRoutineData[category].enumerated() {
                if item.done == true {
                    sortedTodayRoutineData.remove(at: index)
                }
            }
        }
    }
    
    // 사용자에게 보여줄 루틴 데이터 하나의 리스트로 정리
    private func makeShowTodayRoutine() {
        for routines in sortedTodayRoutineData {
            showTodayRoutineData += routines
        }
    }
    
    
    // MARK: - addObserver Func
    
    @objc func tapRecommendRoutineBtn() {
        print("추천 루틴 페이지로 이동")
        let nextVC = RoutineViewController()
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.isReload = true
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    // MARK: - layout, ui set
    
    // tableView의 콘텐츠 높이에 따라 contentView의 높이를 동적으로 조정
    func updateContentViewHeight() {
        self.view.layoutIfNeeded() // 레이아웃 강제 업데이트
        tableView.sizeToFit()
        let tableViewHeight = tableView.contentSize.height
        print("tableViewHeight \(tableViewHeight)")
        let contentHeight = tableViewHeight
                            + 291 // 상단부 고정된 간격
                            + 156 // 하단 버튼들 고정된 간격
        print("contentHeight \(contentHeight)")
        // 스크롤뷰의 콘텐츠 크기 업데이트
        contentScrollView.contentSize = CGSize(width: contentScrollView.frame.width, height: contentHeight)
        
        contentView.snp.updateConstraints {
            $0.height.equalTo(contentHeight)
        }
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
        [topBackgroundView, bottomBackgroundView, contentScrollView].forEach({ view.addSubview($0) })
        [contentView].forEach({ contentScrollView.addSubview($0) })
        [categoryBoxView, tableViewTopView, tableViewTopLabel, tableView, recommendRoutineBtn].forEach({ contentView.addSubview($0) })
        [categoryCollectionView].forEach({ categoryBoxView.addSubview($0) })
        
        self.topBackgroundView.snp.makeConstraints {
            $0.right.left.equalTo(self.view.safeAreaLayoutGuide)
            $0.top.equalTo(view.snp.top)
            $0.bottom.equalTo(view.snp.centerY)
        }
        
        self.bottomBackgroundView.snp.makeConstraints {
            $0.top.equalTo(topBackgroundView.snp.bottom)
            $0.right.left.equalTo(self.view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.snp.bottom)
        }
        
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
        
        self.tableViewTopView.snp.makeConstraints {
            $0.top.equalTo(categoryBoxView.snp.bottom).offset(32)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(106)
        }
        
        self.tableViewTopLabel.snp.makeConstraints {
            $0.top.equalTo(tableViewTopView).inset(40)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(tableViewTopView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(500)
        }
        
        self.recommendRoutineBtn.snp.makeConstraints {
            $0.bottom.equalTo(tableView.snp.bottom)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(48)
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
        print(todayRoutineData.data.count)
        return showTodayRoutineData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodayRoutineCell.identifier, for: indexPath) as? TodayRoutineCell else {
            return UITableViewCell()
        }
        let item = showTodayRoutineData[indexPath.row]
        cell.setContent(routineId: item.routineId, title: item.title, category: item.category, done: item.done)
        
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
        if let selectedCell = tableView.cellForRow(at: indexPath) as? TodayRoutineCell {
            selectedCell.tapCell {
                showToast(view: view, message: "루틴 완료", imageName: "Icon-Circle-Check", withDuration: 0.5, delay: 3.0)
            }
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
