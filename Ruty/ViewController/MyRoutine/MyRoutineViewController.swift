//
//  MyRoutineViewController.swift
//  Ruty
//
//  Created by 정성희 on 3/3/25.
//

import UIKit

class MyRoutineViewController: UIViewController {

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
        $0.backgroundColor = .red
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
        
        print("allRoutinesData: \(allRoutinesData)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        tableView.reloadData()
        
        // 스와이프 뒤로 가기 제스처 다시 활성화
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        //super.viewDidLayoutSubviews()
        self.updateContentViewHeight()
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
    
    // 모든 루틴을 추가해서 추가할 루틴이 없을 경우 헬퍼 텍스트 표기
    func checkRoutineEmpty() {
        let routines = allRoutinesData.flatMap { $0 }
        if routines.isEmpty {
            contentScrollView.addSubview(emptyLabel)
            self.emptyLabel.snp.makeConstraints {
                $0.centerX.centerY.equalToSuperview()
            }
        }
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
                return
            case "소비" :
                selectedCategoryIndex = 1
                return
            case "여가생활" :
                selectedCategoryIndex = 2
                return
            case "자가관리" :
                selectedCategoryIndex = 3
                return
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
        let contentHeight = tableViewHeight
                            + 250 // 기타 고정된 간격
        // 스크롤뷰의 콘텐츠 크기 업데이트
        contentScrollView.contentSize = CGSize(width: contentScrollView.frame.width, height: contentHeight)
        
        contentView.snp.updateConstraints {
            $0.height.equalTo(contentHeight)
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
        
        cell.preViewController = self
        cell.setContent(id: item.routineId, category: item.category, routineName: item.title, markImage: RoutineCategoryImage.shared[item.category] ?? "housing", routineStatusText: "test", dayText: "test", dateText: "test")
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
