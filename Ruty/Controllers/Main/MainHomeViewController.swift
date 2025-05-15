//
//  MainHomeViewController.swift
//  Ruty
//
//  Created by 정성희 on 2/7/25.
//

import UIKit
import Alamofire
import AuthenticationServices

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
    
    private let addRoutineView = UIView().then {
        $0.backgroundColor = UIColor.fill.primary
        $0.layer.cornerRadius = 16
        $0.isUserInteractionEnabled = true
        $0.isExclusiveTouch = true
    }
    
    let addRoutineStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
        $0.distribution = .equalCentering
    }
    
    private let addRoutineLabel = UILabel().then {
        $0.text = "새로운 루틴 추가"
        $0.textColor = .white
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.numberOfLines = 0
    }
    
    private let addRoutineMark = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "Icon-Plus")
    }
    
    private let recommendRoutineBtn = UIButton().then {
        $0.backgroundColor = UIColor.fill.secondary
        $0.layer.cornerRadius = 12
        $0.setTitle("추천 루틴", for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.setTitleColor(UIColor.font.primary, for: .normal)
        $0.addTarget(self, action: #selector(tapRecommendRoutineBtn), for: .touchUpInside)
        $0.isExclusiveTouch = true
    }
    
    private let myRoutineBtn = UIButton().then {
        $0.backgroundColor = UIColor.fill.secondary
        $0.layer.cornerRadius = 12
        $0.setTitle("나의 루틴", for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.setTitleColor(UIColor.font.primary, for: .normal)
        $0.addTarget(self, action: #selector(tapMyRoutineBtn), for: .touchUpInside)
        $0.isExclusiveTouch = true
    }
    
    let deleteBtn = UIButton().then {
        $0.setTitle("회원탈퇴", for: .normal)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.setTitleColor(UIColor.font.tertiary, for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.addTarget(self, action: #selector(tapDeleteBtn), for: .touchUpInside)
        $0.isExclusiveTouch = true
    }
    
    // 카테고리 데이터
    private var categoryLevels = JSONModel.CategoryLevels(message: "", data: [])
    private var sortedCategoryLevels = [JSONModel.CategoryLevel](repeating: JSONModel.CategoryLevel(category: "", level: 1, totalPoints: 0), count: 4)
    private var categoryLevelAfterRoutineDone = JSONModel.CategoryLevelAfterRoutineDone(message: "", data: JSONModel.CategoryLevel(category: "", level: 1, totalPoints: 1))
    
    // 오늘의 루틴 데이터
    private var todayRoutineData = JSONModel.RoutinesResponse(message: "", data: []) // 모든 오늘의 루틴 데이터
    private var sortedTodayRoutineData = [[JSONModel.Routine]](repeating: [JSONModel.Routine](), count: 4) // 카테고리별 정렬 & 완료된 루틴은 삭제된 루틴 데이터
    private var showTodayRoutineData = [JSONModel.Routine]() // 사용자에게 보여질 오늘의 루트 데이터
    
    // 사용자의 모든 루틴 데이터
    private var rawAllRoutinesData = JSONModel.AllRoutineResponse(message: "", data: [])
    private var sortedAllRoutinesData = [[JSONModel.AllRoutine]](repeating: [JSONModel.AllRoutine](), count: 4)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestUserInfo()
        loadCategoryLevel()
        loadTodayData()

        setUI()
        setObserver()
        setupCollectionView()
        setupTableView()
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("뷰 보여짐")
        loadTodayData()
        
        // tap flag 초기화
        isTappedAddRoutine = false
        isTappedRecommendRoutine = false
        isTappedAllRoutine = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateContentViewHeight()
    }
    
    deinit {
        print("MainHomeViewController deinitialized")
    }
    
    // MARK: - api 요청
    
    func requestUserInfo() {
        var url = NetworkManager.shared.getRequestURL(api: "/api/profile")
        NetworkManager.shared.requestAPI(url: url, method: .get, encoding: URLEncoding.default, param: nil) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.AppleUserInfoResponse.self, from: data)
                    DataManager.shared.userNickName = decodedResponse.data.nickName
                    DataManager.shared.socialType = decodedResponse.data.socialType
                } catch {
                    print("추천 JSON 디코딩 오류: \(error)")
                }
            case .failure(let error):
                print("네트워크 api 요청 실패: \(error)")
            }
        }
    }
    
    // 회원 탈퇴 클릭
    @objc func tapDeleteBtn() {
        if DataManager.shared.socialType == "APPLE" {
            let provider = ASAuthorizationAppleIDProvider()
            let requset = provider.createRequest()
            
            // 사용자에게 제공받을 정보를 선택 (이름 및 이메일)
            requset.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [requset])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
        else if DataManager.shared.socialType == "GOOGLE" {
            requestDeleteUser()
        }
        
        else { print("소셜 로그인 정보가 없음") }
    }
    
    // 회원 탈퇴 요청
    func requestDeleteUser() {
        print("\(DataManager.shared.socialType) 탈퇴 요청 시도")
        
        let url = NetworkManager.shared.getRequestURL(api: "/api/profile")
        var param: [String : Any] = [:]
        
        if DataManager.shared.socialType == "APPLE" {
            let model = JSONModel.Delete(code: UserDefaults.standard.string(forKey: "authCode")!)
            guard let jsonData = try? JSONEncoder().encode(model),
                var _param = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else { return }
            param = _param
        }

        NetworkManager.shared.requestAPI(url: url, method: .delete, encoding: URLEncoding.default, param: param) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.APIResponse.self, from: data)
                    if decodedResponse.message == "delete" {
                        print("\(DataManager.shared.socialType) 탈퇴 성공")
                        self.goToLoginPage()
                    }
                    else {
                        print("서버 연결 오류")
                        ErrorViewController.showErrorPage(viewController: self)
                    }

                } catch {
                    ErrorViewController.showErrorPage(viewController: self)
                }
                
            case .failure(let error):
                // 요청이 실패한 경우
                print("탈퇴 API 요청 실패: \(error.localizedDescription)")
                ErrorViewController.showErrorPage(viewController: self)
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
                    print("오늘의 루틴 목록: \(decodedResponse)")
                    self.todayRoutineData = decodedResponse
                    self.sortTodayRoutineData()
                    self.makeShowTodayRoutine()
                    
                    DispatchQueue.main.async {
                        
                        self.updateContentViewHeight()
                        self.checkRoutineEmptyReason()
                        self.tableView.reloadData()
                    }
                } catch {
                    print("JSON 디코딩 오류: \(error)")
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
                    
                    DispatchQueue.main.async {
                        self.categoryCollectionView.reloadData()
                    }
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
    func loadAllData(completion: @escaping () -> ()) {
        let url = NetworkManager.shared.getRequestURL(api: "/api/routine")
        NetworkManager.shared.requestAPI(url: url, method: .get, encoding: URLEncoding.default, param: nil) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.AllRoutineResponse.self, from: data)
                    if decodedResponse.message == "ok" {
                        
                        self.rawAllRoutinesData = decodedResponse
                        self.sortMyRoutineData()
                        completion()
                    }
                    else {
                        print("서버 연결 오류")
                        ErrorViewController.showErrorPage(viewController: self)
                    }
                } catch {
                    print("루틴 JSON 디코딩 오류: \(error)")
                    ErrorViewController.showErrorPage(viewController: self)
                }
            case .failure(let error):
                // 요청이 실패한 경우
                print("API 요청 실패: \(error.localizedDescription)")
                ErrorViewController.showErrorPage(viewController: self)
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
                    if decodedResponse.message == "ok" {
                        self.categoryLevelAfterRoutineDone = decodedResponse
                        let category = self.categoryLevelAfterRoutineDone.data.category
                        let point = self.categoryLevelAfterRoutineDone.data.totalPoints
                        
                        let indexPath = IndexPath(item: categoryIndex[category] ?? 0, section: 0)
                        guard let cell = self.categoryCollectionView.cellForItem(at: indexPath) as? CategoryLevelCell else { return }

                        let preLevel = cell.level

                        cell.setContent(category: category, point: point)
                        
                        // 루틴 삭제후 테이블 fetch
                        self.loadTodayData()
                        self.updateContentViewHeight()
                        
                        // 레벨업 한 경우
                        if preLevel < cell.level {
                            let popUpVC = ModalPopUpViewController()
                            popUpVC.category = category
                            popUpVC.level = cell.level
                            popUpVC.modalPresentationStyle = .overFullScreen
                            self.present(popUpVC, animated: true, completion: nil)
                        }
                    }
                    else {
                        ErrorViewController.showErrorPage(viewController: self)
                    }
                } catch {
                    ErrorViewController.showErrorPage(viewController: self)
                }
            case .failure(let error):
                // 요청이 실패한 경우
                print("API 요청 실패: \(error.localizedDescription)")
                ErrorViewController.showErrorPage(viewController: self)
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
    
    // MARK: - 오늘의 루틴 관련 함수
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
        // 루틴이 다시 생기면 헬퍼 텍스트 제거
        else {
            emptyLabel.removeFromSuperview()
        }
    }
    
    // MARK: - 나의 루틴 관련 함수
    private func sortMyRoutineData() {
        // sortedTodayRoutineData 초기화
        sortedAllRoutinesData = [[JSONModel.AllRoutine]](repeating: [JSONModel.AllRoutine](), count: 4)
        
        for item in rawAllRoutinesData.data {
            switch item.category {
            case "HOUSE" : sortedAllRoutinesData[0].append(item)
            case "MONEY" : sortedAllRoutinesData[1].append(item)
            case "LEISURE" : sortedAllRoutinesData[2].append(item)
            case "SELFCARE" : sortedAllRoutinesData[3].append(item)
            default: break
            }
        }
    }
    
    // MARK: - addObserver Func
    func setObserver() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAddRoutineBtn(_:)))
        addRoutineView.addGestureRecognizer(tapGesture)
    }
    
    var isTappedAddRoutine = false
    @objc func tapAddRoutineBtn(_ sender: UIButton) {
        guard !isTappedAddRoutine else { return }
        
        isTappedAddRoutine = true
        let nextVC = GoalSettingViewController()
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.isRecommendedData = false
        nextVC.preViewController = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    var isTappedRecommendRoutine = false
    @objc func tapRecommendRoutineBtn() {
        guard !isTappedRecommendRoutine else { return }
        
        isTappedRecommendRoutine = true
        RoutineDataProvider.shared.loadRecommendedData {
            let nextVC = RoutineViewController()
            nextVC.modalPresentationStyle = .fullScreen
            nextVC.isReload = true
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    var isTappedAllRoutine = false
    // 나의 모든 루틴 보기 버튼 클릭
    @objc func tapMyRoutineBtn() {
        guard !isTappedAllRoutine else { return }
        
        isTappedAllRoutine = true
        loadAllData {
            let nextVC = MyRoutineViewController()
            nextVC.setAllRoutinesData(data: self.sortedAllRoutinesData)
            nextVC.modalPresentationStyle = .fullScreen
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
        + 48 // 회원 탈퇴 버튼 길이 추가
        + 56 // 새로운 루틴 버튼 길이 추가
        
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
        [categoryBoxView, tableViewTopView, tableViewTopLabel, tableView, addRoutineView, recommendRoutineBtn, myRoutineBtn,  deleteBtn].forEach({ contentView.addSubview($0) })
        [addRoutineStackView].forEach({ addRoutineView.addSubview($0) })
        [addRoutineMark, addRoutineLabel].forEach({ addRoutineStackView.addArrangedSubview($0) })
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
        }
        
        self.addRoutineView.snp.makeConstraints{
            $0.bottom.equalTo(recommendRoutineBtn.snp.top).offset(-20)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(56)
        }
        
        self.addRoutineStackView.snp.makeConstraints{
            $0.center.equalToSuperview()
        }
        
        self.addRoutineMark.snp.makeConstraints {
            $0.height.equalTo(16)
        }
        
        self.recommendRoutineBtn.snp.makeConstraints {
            $0.bottom.equalTo(deleteBtn.snp.top).offset(-20)
            $0.right.equalTo(contentView.snp.centerX).offset(-8)
            $0.left.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        self.myRoutineBtn.snp.makeConstraints {
            $0.bottom.equalTo(deleteBtn.snp.top).offset(-20)
            $0.left.equalTo(contentView.snp.centerX).offset(8)
            $0.right.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        self.deleteBtn.snp.makeConstraints{
            $0.bottom.equalTo(tableView.snp.bottom).inset(20)
            $0.left.right.equalToSuperview().inset(107)
            $0.height.equalTo(48)
        }
        
        self.categoryCollectionView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            $0.left.equalToSuperview().inset(6)
            $0.right.equalToSuperview().inset(6)
        }
    }
    
    private func setUI() {
        view.backgroundColor = UIColor.background.secondary
        // 기본 네비게이션바 비활성화
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func goToLoginPage() {
        let nextVC = LoginViewController()
        self.view.window?.rootViewController = nextVC
        self.view.window?.makeKeyAndVisible()
    }
    
    // label의 rowNumber 에 따른 cellBlock의 height 반환
    private func estimateTextHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
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
                    print("실행취소")
                    isClickedUndo = true // 완료된 루틴 실행 취소
                    selectedCell.isChecked = false // 루틴 cell check 표기 복구
                    
                } nonClickAction: {
                    // 루틴 실행 취소를 누르지 않은 경우
                    // 완료된 루틴 리스트에서 삭제
                    if !isClickedUndo {
                        self.blindDoneTodayRoutine(routineId: selectedCell.routineId)
                        print("루틴 실행완료")
                    }
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // cell 높이 동적으로 조절
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = showTodayRoutineData[indexPath.row]
        
        let newHeight = estimateTextHeight(text: item.title, width: tableView.frame.width - 40, font: UIFont(name: Font.semiBold.rawValue, size: 14)!)
        return newHeight + 55 // 기본 마진 추가
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

extension MainHomeViewController: ASAuthorizationControllerPresentationContextProviding {
    // 인증창을 보여주기 위한 메서드 (인증창을 보여 줄 화면을 설정)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.view.window ?? UIWindow()
    }
}

extension MainHomeViewController: ASAuthorizationControllerDelegate {
    // 로그인 실패 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
    }
    
    // Apple ID 로그인에 성공한 경우, 사용자의 인증 정보를 확인하고 필요한 작업을 수행합니다
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            if let authorizationCodeData = appleIdCredential.authorizationCode,
               let authorizationCodeString = String(data: authorizationCodeData, encoding: .utf8) {
                
                UserDefaults.standard.set(authorizationCodeString, forKey: "authCode")
                requestDeleteUser()
                
            } else {
                print("authorizationCode 변환에 실패했습니다.")
            }
            
        default: break
        }
    }
}
