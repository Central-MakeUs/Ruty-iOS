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
        $0.backgroundColor = .clear
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
    
    private let emptyLabel = UILabel().then {
        $0.text = ""
        $0.textColor = UIColor.font.tertiary
        $0.textAlignment = .center
        $0.font = UIFont(name: Font.regular.rawValue, size: 16)
        $0.numberOfLines = 0
    }
    
    private let recommendRoutineBtn = UIButton().then {
        $0.backgroundColor = UIColor.fill.secondary
        $0.layer.cornerRadius = 12
        $0.setTitle("추천 루틴", for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.setTitleColor(UIColor.font.primary, for: .normal)
        $0.addTarget(self, action: #selector(tapRecommendRoutineBtn), for: .touchUpInside)
    }
    
    let deleteBtn = UIButton().then {
        $0.setTitle("회원탈퇴", for: .normal)
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 10
        $0.setTitleColor(.white, for: .normal)
        $0.addTarget(self, action: #selector(tapDeleteBtn), for: .touchUpInside)
    }

    // 카테고리 데이터
    private var categoryLevels = JSONModel.CategoryLevels(message: "", data: [])
    private var sortedCategoryLevels = [JSONModel.CategoryLevel](repeating: JSONModel.CategoryLevel(category: "", level: 1, totalPoints: 1), count: 4)
    private var categoryLevelAfterRoutineDone = JSONModel.CategoryLevelAfterRoutineDone(message: "", data: JSONModel.CategoryLevel(category: "", level: 1, totalPoints: 1))
    
    // 루틴 데이터
    private var todayRoutineData = JSONModel.RoutinesResponse(message: "", data: []) // 모든 오늘의 루틴 데이터
    private var sortedTodayRoutineData = [[JSONModel.Routine]](repeating: [JSONModel.Routine](), count: 4) // 카테고리별 정렬 & 완료된 루틴은 삭제된 루틴 데이터
    private var showTodayRoutineData = [JSONModel.Routine]() // 사용자에게 보여질 루트 데이터
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategoryLevel()
        loadTodayData()

        setUI()
        setupCollectionView()
        setupTableView()
        setLayout()
        //checkRoutineEmptyReason()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("view did layout subviews")
        self.updateContentViewHeight()
    }
    
    // MARK: - api 요청
    
    @objc func tapDeleteBtn() {
        let url = NetworkManager.shared.getRequestURL(api: "/api/profile")
        //let param : Parameters = ["code" : authorizationCodeString]
        let param = JSONModel.Delete(code: UserDefaults.standard.string(forKey: "authCode")!)
        print("param \(param)")
        guard let jsonData = try? JSONEncoder().encode(param),
              var param = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else { return }
        NetworkManager.shared.requestAPI(url: url, method: .delete, encoding: JSONEncoding.default, param: param) { result in
            switch result {
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("모든 루틴 JSON 문자열: \(jsonString)")
                } else {
                    print("Data를 문자열로 변환할 수 없습니다.")
                }
            case .failure(let error):
                // 요청이 실패한 경우
                print("API 요청 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // 오늘의 루틴 요청
    func loadTodayData() {
        let url = NetworkManager.shared.getRequestURL(api: "/api/routine/today")
        NetworkManager.shared.requestAPI(url: url, method: .get, encoding: URLEncoding.default, param: nil) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.RoutinesResponse.self, from: data)
                    self.todayRoutineData = decodedResponse
                    self.sortTodayRoutineData()
                    self.makeShowTodayRoutine()
                    
                    self.tableView.reloadData()
                    self.checkRoutineEmptyReason()
                } catch {
                    print("오늘의 루틴 데이터 JSON 디코딩 오류: \(error)")
                }
                
            case .failure(let error):
                // 요청이 실패한 경우
                print("API 요청 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // 카테고리 별 레벨 조회
    func loadCategoryLevel() {
        let url = NetworkManager.shared.getRequestURL(api: "/api/routine/category")
        NetworkManager.shared.requestAPI(url: url, method: .get, encoding: URLEncoding.default, param: nil) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.CategoryLevels.self, from: data)
                    self.categoryLevels = decodedResponse
                    print("categoryLevels \(self.categoryLevels)")
                    self.sortCategoryLevel()
                    self.categoryCollectionView.reloadData()
                } catch {
                    print("JSON 디코딩 오류: \(error)")
                }
            case .failure(let error):
                // 요청이 실패한 경우
                print("API 요청 실패: \(error.localizedDescription)")
            }
        }
    }
     
    // 사용자의 모든 루틴 요청
    func loadAllData() {
        let url = NetworkManager.shared.getRequestURL(api: "/api/routine")
        NetworkManager.shared.requestAPI(url: url, method: .get, encoding: URLEncoding.default, param: nil) { result in
            switch result {
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("모든 루틴 JSON 문자열: \(jsonString)")
                } else {
                    print("Data를 문자열로 변환할 수 없습니다.")
                }
                
            case .failure(let error):
                // 요청이 실패한 경우
                print("API 요청 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // 완료한 루틴 오늘의 루틴 리스트에서 삭제
    func blindDoneTodayRoutine(routineId: Int) {
        let url = NetworkManager.shared.getRequestURL(api: "/api/routine/\(routineId)/state")
        NetworkManager.shared.requestAPI(url: url, method: .put, encoding: URLEncoding.queryString, param: nil) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.CategoryLevelAfterRoutineDone.self, from: data)
                    self.categoryLevelAfterRoutineDone = decodedResponse
                    print("categoryLevels \(self.categoryLevelAfterRoutineDone)")
                    
                    let category = self.categoryLevelAfterRoutineDone.data.category
                    let point = self.categoryLevelAfterRoutineDone.data.totalPoints
                    
                    let indexPath = IndexPath(item: categoryIndex[category] ?? 0, section: 0)
                    guard let cell = self.categoryCollectionView.cellForItem(at: indexPath) as? CategoryLevelCell else { return }
                    cell.setContent(category: category, point: point)
                } catch {
                    print("JSON 디코딩 오류: \(error)")
                }
                
                // 루틴 삭제후 테이블 fetch
                self.loadTodayData()
                
            case .failure(let error):
                // 요청이 실패한 경우
                print("API 요청 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 카테고리 레벨 관련 함수
    // 카테고리 레벨 요구사항대로 정렬
    func sortCategoryLevel() {
        for category in categoryLevels.data {
            switch category.category {
            case "HOUSE": sortedCategoryLevels[0] = JSONModel.CategoryLevel(category: category.category, level: category.level, totalPoints: category.totalPoints)
            case "MONEY": sortedCategoryLevels[1] = JSONModel.CategoryLevel(category: category.category, level: category.level, totalPoints: category.totalPoints)
            case "LEISURE": sortedCategoryLevels[2] = JSONModel.CategoryLevel(category: category.category, level: category.level, totalPoints: category.totalPoints)
            case "SELFCARE": sortedCategoryLevels[3] = JSONModel.CategoryLevel(category: category.category, level: category.level, totalPoints: category.totalPoints)
            default: return
            }
        }
    }
    
    // MARK: - 루틴 관련 함수
    // 루틴 카테고리별로 정렬, 완료된 루틴은 제외
    private func sortTodayRoutineData() {
        // sortedTodayRoutineData 초기화
        sortedTodayRoutineData = [[JSONModel.Routine]](repeating: [JSONModel.Routine](), count: 4)
        
        for item in todayRoutineData.data {
            if item.done == false {
                switch item.category {
                case "HOUSE" : sortedTodayRoutineData[0].append(item)
                case "MONEY" : sortedTodayRoutineData[1].append(item)
                case "LEISURE" : sortedTodayRoutineData[2].append(item)
                case "SELFCARE" : sortedTodayRoutineData[3].append(item)
                default: break
                }
            }
        }
        print("sortedTodayRoutineData 정렬, done 제거됨:  \(sortedTodayRoutineData)")
    }
    
    // 사용자에게 보여줄 루틴 데이터 하나의 리스트로 정리
    private func makeShowTodayRoutine() {
        showTodayRoutineData = [JSONModel.Routine]() // showTodayRoutineData 초기화
        
        for routines in sortedTodayRoutineData {
            showTodayRoutineData += routines
        }
    }
    
    // 보여줄 오늘의 루틴 리스트가 비었을 경우
    // 오늘 실천할 루틴이 아예 없는건지 오늘 루틴을 모두 완료한건지 판단
    func checkRoutineEmptyReason() {
        if showTodayRoutineData.isEmpty {
            // 오늘 실천할 루틴이 아예 없는경우
            if todayRoutineData.data.isEmpty {
                emptyLabel.text = """
                현재 실천 중인 루틴이 없어요.
                새로운 루틴을 만들어볼까요?
                """
            }
            // 오늘 루틴을 모두 완료
            else { emptyLabel.text = "대단해요! 오늘의 계획을 모두 이뤄냈어요" }
            
            contentView.addSubview(emptyLabel)
            self.emptyLabel.snp.makeConstraints {
                $0.top.equalTo(tableViewTopLabel.snp.bottom).offset(146)
                $0.centerX.equalToSuperview()
            }
        }
    }
    
    // MARK: - addObserver Func
    @objc func tapRecommendRoutineBtn() {
        RoutineDataProvider.shared.loadRecommendedData {
            let nextVC = RoutineViewController()
            nextVC.modalPresentationStyle = .fullScreen
            nextVC.isReload = true
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    // MARK: - layout, ui set
    // tableView의 콘텐츠 높이에 따라 contentView의 높이를 동적으로 조정
    func updateContentViewHeight() {
        self.view.layoutIfNeeded() // 레이아웃 강제 업데이트
        tableView.sizeToFit()
        let tableViewHeight = tableView.contentSize.height
        var contentHeight = tableViewHeight
                            + 291 // 상단부 고정된 간격
                            + 156 // 하단 버튼들 고정된 간격
        
        // 스크롤뷰 콘텐츠 최소 길이를 기기 화면 크기로 지정
        let screenHeight = view.safeAreaLayoutGuide.layoutFrame.height
        if contentHeight < screenHeight {
            contentHeight = screenHeight
        }
        
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
        [deleteBtn, categoryBoxView, tableViewTopView, tableViewTopLabel, tableView, recommendRoutineBtn].forEach({ contentView.addSubview($0) })
        [categoryCollectionView].forEach({ categoryBoxView.addSubview($0) })
        
        // 계정 탈퇴 테스트할때 넣고 하기
//        self.deleteBtn.snp.makeConstraints({
//            $0.top.equalToSuperview()
//            $0.centerY.centerX.equalToSuperview()
//            $0.height.width.equalTo(56)
//        })
        
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
            $0.bottom.equalTo(tableView.snp.bottom).inset(20)
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
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var isClickedUndo = false
        
        // 클릭한 cell 에 접근
        if let selectedCell = tableView.cellForRow(at: indexPath) as? TodayRoutineCell {
            selectedCell.tapCell {
                showToast(view: view, message: "루틴 완료", imageName: "Icon-Circle-Check", withDuration: 0.5, delay: 4.0, buttonTitle: "실행 취소") {
                    // 루틴 실행 취소
                    isClickedUndo = true // 완료된 루틴 실행 취소
                    selectedCell.isChecked = false // 루틴 cell check 표기 복구
                    
                } nonClickAction: {
                    // 루틴 실행 취소를 누르지 않은 경우
                    // 완료된 루틴 리스트에서 삭제
                    if !isClickedUndo {
                        self.blindDoneTodayRoutine(routineId: selectedCell.routineId)
                    }
                }
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
        cell.setContent(category: sortedCategoryLevels[indexPath.row].category, point: sortedCategoryLevels[indexPath.row].totalPoints)
        cell.setupLayers()
        return cell
    }
}
