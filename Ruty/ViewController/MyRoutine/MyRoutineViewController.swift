//
//  MyRoutineViewController.swift
//  Ruty
//
//  Created by 정성희 on 3/3/25.
//

import UIKit
import Alamofire

class MyRoutineViewController: UIViewController {

    // 사용자의 모든 루틴 데이터
    private var rawAllRoutinesData = JSONModel.AllRoutineResponse(message: "", data: [])
    private var sortedAllRoutinesData = [[JSONModel.AllRoutine]](repeating: [JSONModel.AllRoutine](), count: 4)
    
    private let contentScrollView = UIScrollView().then {
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let backBtn = UIButton().then {
        $0.setImage(UIImage(named: "back"), for: .normal)
        $0.addTarget(self, action: #selector(moveToBackPage), for: .touchUpInside)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "나의 루틴"
        $0.textColor = UIColor(3, 7, 18, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 24)
        $0.numberOfLines = 1
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "지금까지 실천한 루틴을 정리해봤어요"
        $0.textColor = UIColor(107, 114, 128, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.regular.rawValue, size: 14)
        $0.numberOfLines = 1
    }
    
    private let emptyLabel = UILabel().then {
        $0.text = "추가한 루틴이 없어요. 루틴을 추가해보세요!"
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
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    
    
    private let categoryType = ["주거", "소비", "여가생활", "자기관리"]
    private var appearCategory: [String] = []
    private var selectedCategoryIndex: Int = 0 // 현재 선택된 카테고리
    
    
    private var allRoutinesData = [[JSONModel.AllRoutine]](repeating: [JSONModel.AllRoutine](), count: 4) // 사용자의 모든 루틴 데이터
    private var showAllRoutineData = [JSONModel.AllRoutine]() // 사용자에게 보여질 모든 루트 데이터
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        setUI()
        setupTableView()
        setupCollectionView()
        
        appearOnlyExistCategory() // 존재하는 카테고리 종류만 키워드에 노출될 수 있도록 리스트업
        checkFirstCategory()
        
        checkRoutineEmpty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 스와이프 뒤로 가기 제스처 다시 활성화
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        updateData()
    }
    
    override func viewDidLayoutSubviews() {
        self.updateContentViewHeight()
    }
    
    // MARK: - API 요청
    
    func updateData() {
        let url = NetworkManager.shared.getRequestURL(api: "/api/routine")
        NetworkManager.shared.requestAPI(url: url, method: .get, encoding: URLEncoding.default, param: nil) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.AllRoutineResponse.self, from: data)
                    if decodedResponse.message == "ok" {
                        self.rawAllRoutinesData = decodedResponse
                        self.sortMyRoutineData()
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

    // MARK: - get, set
    func setAllRoutinesData(data: [[JSONModel.AllRoutine]]) {
        allRoutinesData = data
    }
    
    // MARK: - tableView
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none // cell 라인 없애기
        tableView.register(MyRoutineCell.self, forCellReuseIdentifier: MyRoutineCell.identifier)
    }
    
    // 루틴을 전혀 추가하지 않아서 표기할 루틴이 없을 때 헬퍼 텍스트 표기
    func checkRoutineEmpty() {
        let routines = allRoutinesData.flatMap { $0 }
        if routines.isEmpty {
            contentScrollView.addSubview(emptyLabel)
            self.emptyLabel.snp.makeConstraints {
                $0.centerX.centerY.equalToSuperview()
            }
        }
    }
    
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
        allRoutinesData = sortedAllRoutinesData
        self.tableView.reloadData()
    }
    
    
    // MARK: - collectionView
    private func setupCollectionView() {
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
    }
    
    // 존재하는 카테고리 종류만 키워드에 노출될 수 있도록 리스트업
    func appearOnlyExistCategory() {
        for item in allRoutinesData {
            if item.isEmpty == false {
                switch item[0].category {
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
        if appearCategory.count != 0 {
            switch appearCategory[0] {
            case "주거" :
                selectedCategoryIndex = 0
                break
            case "소비" :
                selectedCategoryIndex = 1
                break
            case "여가생활" :
                selectedCategoryIndex = 2
                break
            case "자기관리" :
                selectedCategoryIndex = 3
                break
            default: break
            }
            
            // 처음 0번째 카테고리 셀을 선택된 상태로 설정
            let firstIndexPath = IndexPath(item: 0, section: 0)
            categoryCollectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .left)
        }
    }
    
    // MARK: - laout, UI
    
    // tableView의 콘텐츠 높이에 따라 contentView의 높이를 동적으로 조정
    func updateContentViewHeight() {
        
        self.view.layoutIfNeeded() // 레이아웃 강제 업데이트
        tableView.sizeToFit()
        let tableViewHeight = tableView.contentSize.height
        var contentHeight = tableViewHeight
                            + 250 // 기타 고정된 간격
        // 스크롤뷰의 콘텐츠 크기 업데이트
        contentScrollView.contentSize = CGSize(width: contentScrollView.frame.width, height: contentHeight)
        
        // 스크롤뷰 콘텐츠 최소 길이를 기기 화면 크기로 지정
        let screenHeight = view.safeAreaLayoutGuide.layoutFrame.height
        if contentHeight < screenHeight {
            contentHeight = screenHeight
        }
        
        DispatchQueue.main.async {
            self.contentView.snp.updateConstraints {
                $0.height.equalTo(contentHeight)
            }
        }
    }
    
    func setUI() {
        view.backgroundColor = .white
    }
    
    func setLayout() {
        [contentScrollView].forEach({ view.addSubview($0) })
        [contentView].forEach({ contentScrollView.addSubview($0) })
        [backBtn, titleLabel, descriptionLabel, categoryCollectionView, tableView].forEach({ contentView.addSubview($0) })
        
        self.contentScrollView.snp.makeConstraints {
            $0.top.bottom.right.left.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.contentView.snp.makeConstraints {
            $0.top.bottom.right.left.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(1000)
        }
        
        self.backBtn.snp.makeConstraints {
            $0.top.left.equalToSuperview().inset(20)
            $0.height.width.equalTo(24)
        }
        
        self.titleLabel.snp.makeConstraints({
            $0.top.equalTo(backBtn.snp.bottom).offset(28)
            $0.left.right.equalToSuperview().inset(20)
        })
        
        self.descriptionLabel.snp.makeConstraints({
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(20)
        })
        
        self.categoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(28)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(38)
        }
        
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(categoryCollectionView.snp.bottom).offset(28)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().inset(40)
        }
    }
    
    @objc func moveToBackPage() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - 데이터 변환
    func convertDays(_ days: [String]) -> String {
        // 요일의 순서와 한글 매핑
        let dayOrder: [String: Int] = [
            "MON": 1, "TUE": 2, "WED": 3, "THU": 4, "FRI": 5, "SAT": 6, "SUN": 7
        ]
        let dayKorean: [String: String] = [
            "MON": "월", "TUE": "화", "WED": "수", "THU": "목", "FRI": "금", "SAT": "토", "SUN": "일"
        ]
        
        // 배열이 비어있으면 빈 문자열 반환
        guard !days.isEmpty else { return "" }
        
        // 요일 코드를 순서대로 정렬
        let sortedDays = days.sorted {
            (dayOrder[$0] ?? 0) < (dayOrder[$1] ?? 0)
        }
        
        // 정렬된 요일들을 한글로 변환
        let sortedKoreanDays = sortedDays.compactMap { dayKorean[$0] }
        
        // 배열에 하나의 요소만 있으면 그대로 반환
        guard sortedKoreanDays.count > 1 else {
            return sortedKoreanDays.first ?? ""
        }
        
        // 정렬된 요일들이 연속적인지 검사
        var isContinuous = true
        for i in 1..<sortedDays.count {
            // 만약 인덱스 차이가 1이 아니라면 연속이 아님
            if let prev = dayOrder[sortedDays[i-1]], let current = dayOrder[sortedDays[i]] {
                if current - prev != 1 {
                    isContinuous = false
                    break
                }
            } else {
                isContinuous = false
                break
            }
        }
        
        // 연속적인 경우: 첫번째와 마지막을 '-'로 연결 (예: "월-금")
        if isContinuous {
            return "\(sortedKoreanDays.first!)-\(sortedKoreanDays.last!)"
        } else {
            // 그렇지 않으면 콤마로 연결 (예: "수,금")
            return sortedKoreanDays.joined(separator: ",")
        }
    }
}

extension MyRoutineViewController : UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRoutinesData[selectedCategoryIndex].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyRoutineCell.identifier, for: indexPath) as? MyRoutineCell else {
            return UITableViewCell()
        }
        let item = allRoutinesData[selectedCategoryIndex][indexPath.row]
        
        let startDate = item.startDate.replacingOccurrences(of: "-", with: ".")
        let endDate = item.endDate.replacingOccurrences(of: "-", with: ".")
        let dateText = "\(startDate) - \(endDate)"
        
        let dayText = convertDays(item.weekList)
        
        cell.preViewController = self
        cell.setContent(id: item.routineId, category: item.category, routineName: item.title, markImage: RoutineCategoryImage.shared[item.category] ?? "housing", routineStatusText: item.routineProgress, dayText: dayText, dateText: dateText)
        cell.setupLayout()

        // cell 클릭시 보이게 되는 회색 배경색 제거
        let background = UIView()
        background.backgroundColor = .clear
        cell.selectedBackgroundView = background

        return cell
    }
    
    // cell 높이 동적으로 조절
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = allRoutinesData[selectedCategoryIndex][indexPath.row]
        
        let newHeight = estimateTextHeight(text: item.title, width: tableView.frame.width - 40, font: UIFont(name: Font.semiBold.rawValue, size: 20)!)
        return newHeight + 200 // 기본 마진 추가
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

extension MyRoutineViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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

extension MyRoutineViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // 스와이프 제스처 허용
    }
}
