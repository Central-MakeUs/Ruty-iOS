//
//  RoutineViewController.swift
//  Ruty
//
//  Created by 정성희 on 1/29/25.
//

import UIKit

class RoutineViewController: UIViewController {

    private let contentScrollView = UIScrollView().then {
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = .white
    }
    
    let titleLabel = UILabel().then {
        $0.text = "맞춤형 루틴 추천"
        $0.textColor = UIColor(3, 7, 18, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 24)
        $0.numberOfLines = 1
    }
    
    let descriptionLabel1 = UILabel().then {
        $0.text = "알려주신 정보들을 기반으로 안정적인 생활을 위한"
        $0.textColor = UIColor(107, 114, 128, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.regular.rawValue, size: 14)
        $0.numberOfLines = 1
    }
    
    let descriptionLabel2 = UILabel().then {
        $0.text = "루틴을 추천해 드릴게요."
        $0.textColor = UIColor(107, 114, 128, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.regular.rawValue, size: 14)
        $0.numberOfLines = 1
    }
    
    private let emptyLabel = UILabel().then {
        $0.text = "추천받은 모든 루틴을 추가했어요"
        $0.textColor = UIColor.font.tertiary
        $0.textAlignment = .center
        $0.font = UIFont(name: Font.regular.rawValue, size: 16)
        $0.numberOfLines = 0
    }
    
    private let tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.separatorStyle = .singleLine
        $0.isScrollEnabled = false
    }
    
    private let categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal // 가로 스크롤 설정
        layout.minimumLineSpacing = 10       // 셀 간격
        layout.minimumInteritemSpacing = 10  // 아이템 간격

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    let moveToMainBtn = UIButton().then {
        $0.backgroundColor = UIColor(31, 41, 55, 1)
        $0.layer.cornerRadius = 16
        $0.setTitle("메인 화면으로 이동", for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.setTitleColor(.white, for: .normal)
        $0.addTarget(self, action: #selector(tapMoveToMainBtn), for: .touchUpInside)
        $0.isExclusiveTouch = true
    }
    
    private let categoryType = ["주거", "소비", "여가생활", "자기관리"]
    
    private var appearCategory: [String] = []
    
    private var selectedCategoryIndex: Int = 0 // 현재 선택된 카테고리
    
    private var routinesData = [[JSONModel.RecommendedRoutine]]()
    
    private var addRoutineIdList = [Int]()
    
    var isReload: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setupTableView()
        setupCollectionView()
        setLayout()
        addObserver()
        
        // 실제는 아래 코드 주석빼고 실행
        setAIData()
        
        //디버깅용
        //setMetaData()
        
        appearOnlyExistCategory() // 존재하는 카테고리 종류만 키워드에 노출될 수 있도록 리스트업
        checkFirstCategory() // 화면에 바로 표기할 첫번째 카테고리 index 설정
        
        // tableView의 팬 제스처를 contentScrollView로 전달
        // tableView 의 스크롤은 안되더라도 클릭 제스쳐는 작동하게함
        contentScrollView.panGestureRecognizer.require(toFail: tableView.panGestureRecognizer)
        
        if appearCategory.count != 0 { selectFirstCategory() }
        
        checkRoutineEmpty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        // 온보딩에서 현재 뷰를 로드한 경우
        if !isReload {
            // 기본 네비게이션바 비활성화
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
        
        // 메인홈에서 현재 뷰를 다시 로드한 경우
        else {
            // 스와이프 뒤로 가기 제스처 다시 활성화
            navigationController?.interactivePopGestureRecognizer?.delegate = self
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
        
        // tap flag 초기화
        isTappedMovePage = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateContentViewHeight()
    }
    
    deinit {
        print("RoutineViewController deinitialized")
    }
    
    // MARK: - 카테고리 관련 함수
    
    // 처음 0번째 카테고리 셀을 선택된 상태로 설정
    // 처음에 카테고리를 클릭하지 않아도 첫번재 카테고리가 자동으로 선택되어 있게 함
    func selectFirstCategory() {
        let firstIndexPath = IndexPath(item: 0, section: 0)
        categoryCollectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .left)
    }
    
    // 존재하는 카테고리 종류만 키워드에 노출될 수 있도록 리스트업
    func appearOnlyExistCategory() {
        for category in routinesData {
            if category.isEmpty == false {
                switch category[0].category {
                case "HOUSE" : appearCategory.append("주거")
                case "MONEY" : appearCategory.append("소비")
                case "LEISURE" : appearCategory.append("여가생활")
                case "SELFCARE" : appearCategory.append("자기관리")
                default: break
                }
            }
        }
    }
    
    // 화면에 바로 표기할 첫번째 카테고리 index 설정
    func checkFirstCategory() {
        for category in routinesData {
            if category.isEmpty == false {
                switch category[0].category {
                case "HOUSE" :
                    selectedCategoryIndex = 0
                    return
                case "MONEY" :
                    selectedCategoryIndex = 1
                    return
                case "LEISURE" :
                    selectedCategoryIndex = 2
                    return
                case "SELFCARE" :
                    selectedCategoryIndex = 3
                    return
                default: break
                }
            }
        }
    }
    
    // MARK: - route tableView 관련 함수
    
    // tableView의 콘텐츠 높이에 따라 contentView의 높이를 동적으로 조정
    func updateContentViewHeight() {
        self.view.layoutIfNeeded() // 레이아웃 강제 업데이트
        tableView.sizeToFit()
        let tableViewHeight = tableView.contentSize.height
        let contentHeight = tableViewHeight
                            + titleLabel.frame.height
                            + descriptionLabel1.frame.height
                            + descriptionLabel2.frame.height
                            + categoryCollectionView.contentSize.height
                            + 115 // 기타 고정된 간격
        // 스크롤뷰의 콘텐츠 크기 업데이트
        contentScrollView.contentSize = CGSize(width: contentScrollView.frame.width, height: contentHeight)
        
        contentView.snp.updateConstraints {
            $0.height.equalTo(contentHeight)
        }
    }
    
    // 모든 루틴을 추가해서 추가할 루틴이 없을 경우 헬퍼 텍스트 표기
    func checkRoutineEmpty() {
        let routines = routinesData.flatMap { $0 }
        if routines.isEmpty {
            contentScrollView.addSubview(emptyLabel)
            self.emptyLabel.snp.makeConstraints {
                $0.centerX.centerY.equalToSuperview()
            }
        }
    }
    
    // 추가한 루틴 id 를 deactive 할 리스트에 추가
    @objc func deactivateRoutine(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let routineId = userInfo["id"] as? Int else { return }
        addRoutineIdList.append(routineId)
    }
    
    // MARK: - tap 함수
    var isTappedMovePage = false
    @objc func moveToSettingPage(_ notification: Notification) {
        guard !isTappedMovePage else { return }
        isTappedMovePage = true
        
        guard let userInfo = notification.userInfo else { return }
        guard let routineName = userInfo["routineName"] as? String else { return }
        guard let id = userInfo["id"] as? Int else { return }
        guard let category = userInfo["category"] as? String else { return }
        guard let description = userInfo["description"] as? String else { return }

        let secondVC = GoalSettingViewController()
        secondVC.modalPresentationStyle = .fullScreen
        
        secondVC.isRecommendedData = true
        secondVC.preViewController = self
        secondVC.id = id
        secondVC.routineDescription = description
        secondVC.category = category
        secondVC.routineName = routineName
        guard let navigationController = navigationController else { return }
        navigationController.pushViewController(secondVC, animated: true)
    }
    
    @objc func tapMoveToMainBtn() {
        DispatchQueue.main.async {
            let secondVC = MainHomeViewController()
            secondVC.modalPresentationStyle = .fullScreen
            self.navigationController?.setViewControllers([secondVC], animated: true)
        }
    }
    
    // MARK: - ui 기본 설정 및 layout
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(moveToSettingPage(_:)), name: Notification.Name("moveToGoalSettingVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deactivateRoutine(_:)), name: Notification.Name("AddRoutine"), object: nil)

    }
    
    private func setupCollectionView() {
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none // cell 라인 없애기
        tableView.register(RoutineCell.self, forCellReuseIdentifier: RoutineCell.identifier)
    }
    
    func setUI() {
        view.backgroundColor = .white
    }
    
    func setLayout() {
        [contentScrollView, moveToMainBtn].forEach({ view.addSubview($0) })
        [contentView].forEach({ contentScrollView.addSubview($0) })
        [titleLabel, descriptionLabel1, descriptionLabel2, categoryCollectionView, tableView].forEach({ contentView.addSubview($0) })
        
        self.contentScrollView.snp.makeConstraints {
            $0.bottom.equalTo(moveToMainBtn.snp.top).offset(-20)
            $0.top.right.left.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.contentView.snp.makeConstraints {
            $0.top.bottom.right.left.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        self.titleLabel.snp.makeConstraints({
            $0.top.equalToSuperview().offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        })
        
        self.descriptionLabel1.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        })
        
        self.descriptionLabel2.snp.makeConstraints({
            $0.top.equalTo(descriptionLabel1.snp.bottom).offset(3)
            $0.leading.trailing.equalToSuperview().inset(20)
        })
        
        self.categoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel2.snp.bottom).offset(25)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(38)
        }
        
        self.tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(213)
            $0.bottom.left.right.equalToSuperview()
        }
        
        self.moveToMainBtn.snp.makeConstraints {
            $0.right.left.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(56)
        }
    }

    
    // MARK: - Debugging func
    func setMetaData() {
        routinesData = [[
            JSONModel.RecommendedRoutine(id: 1, title: "퇴근", description: "배", category: "HOUSE"),
            JSONModel.RecommendedRoutine(id: 1, title: "집에가고싶어요", description: "이정도 길이면 될까요 이정도 길이면 될까요 이정도 길이면 될까요?", category: "HOUSE"),
            JSONModel.RecommendedRoutine(id: 1, title: "퇴근 후 나를 위한 한 끼 만들기퇴근 후 나를 위한 한 끼 만들기", description: "배달 음식을 자주 시키는 이유 중 하나는 손쉬운 해결책을 찾는 것인데, 간단한 집밥을 만들어 먹는 습관을 들이면 배달 음식에 대한 의존도를 줄일 수 있습니다.", category: "HOUSE")],
            [],
            [JSONModel.RecommendedRoutine(id: 1, title: "여가", description: "생활", category: "LEISURE"),
             JSONModel.RecommendedRoutine(id: 1, title: "게임하기", description: "겜겜", category: "LEISURE"),
             JSONModel.RecommendedRoutine(id: 1, title: "게임하기게임하기게임하기게임하기게임하기", description: "게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임하기게임", category: "LEISURE")],
            [JSONModel.RecommendedRoutine(id: 1, title: "자기관리", description: "생활", category: "SELFCARE"),
             JSONModel.RecommendedRoutine(id: 1, title: "게임하기", description: "겜겜", category: "SELFCARE"),
             JSONModel.RecommendedRoutine(id: 1, title: "게임하기게임하기게임하기게임하기게임하기", description: "자기관리", category: "SELFCARE")]
        ]
    }
    
    func setAIData() {
        routinesData = RoutineDataProvider.shared.loadRoutinesData()
    }
}

extension RoutineViewController : UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routinesData[selectedCategoryIndex].count // 현재 선택된 카테고리의 데이터의 수 탐색
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoutineCell.identifier, for: indexPath) as? RoutineCell else {
            return UITableViewCell()
        }
        let item = routinesData[selectedCategoryIndex][indexPath.row]
        
        var isAdd = false
        if addRoutineIdList.contains(item.id) { isAdd = true }
        
        cell.setContent(id: item.id, category: item.category, routineName: item.title, description: item.description, markImage: RoutineCategoryImage.shared[item.category] ?? "housing", isAdd: isAdd)
        
        // cell 클릭시 보이게 되는 회색 배경색 제거
        let background = UIView()
        background.backgroundColor = .clear
        cell.selectedBackgroundView = background
        
        cell.setupLayout()
        
        return cell
    }
    
    // cell 높이 동적으로 조절
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = routinesData[selectedCategoryIndex][indexPath.row]
        
        let newHeight = estimateTextHeight(text: item.description, width: tableView.frame.width - 40, font: UIFont(name: Font.regular.rawValue, size: 14)!) + estimateTextHeight(text: item.title, width: tableView.frame.width - 40, font: UIFont(name: Font.semiBold.rawValue, size: 20)!)
        return newHeight + 160 // 기본 마진 추가
    }
    
    // label의 rowNumber 에 따른 cellBlock의 height 반환
    func estimateTextHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension RoutineViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appearCategory.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.item == 0 {
            cell.isClicked = true
        }

        cell.setContent(category: appearCategory[indexPath.row])
        return cell
    }

    // 셀 크기 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = appearCategory[indexPath.row]
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: Font.medium.rawValue, size: 14)
        
        // 패딩 추가
        let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 40))
        return CGSize(width: size.width + 40, height: 38)
    }
    
    // category cell 클릭 이벤트
    // 선택된 cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch appearCategory[indexPath.row] {
        case "주거": selectedCategoryIndex = 0
        case "소비": selectedCategoryIndex = 1
        case "여가생활": selectedCategoryIndex = 2
        case "자기관리": selectedCategoryIndex = 3
        default: break
        }
        tableView.reloadData() // 선택된 카테고리에 맞게 테이블뷰 데이터 업데이트
        updateContentViewHeight()
        
        // 클릭한 cell 의 isClicked true 로 설정
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell {
            cell.isClicked = true
        }
    }
    
    // 선택 해제된 cell
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // 선택 해제된 cell 의 isClicked 된 false로 설정
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell {
            cell.isClicked = false
        }
    }
}

extension RoutineViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // 스와이프 제스처 허용
    }
}
