//
//  GoalSettingViewController.swift
//  Ruty
//
//  Created by 정성희 on 2/3/25.
//

import UIKit
import Alamofire

class GoalSettingViewController: UIViewController {
    
    // false -> 루틴 직접 추가
    // true -> 추천된 루틴 추가
    var isRecommendedData : Bool!
    private var selectedCategoryIndex: Int = 0 // 현재 선택된 카테고리
    private var categoryList: [String] = ["주거", "소비", "여가생활", "자기관리"]
    
    var preViewController: UIViewController?
    
    var id: Int?
    var category: String?
    var routineDescription: String?
    var routineName: String?
    
    let maxTextCount = 50
    var vibrationValue = 1.0
    
    let days = ["월", "화", "수", "목", "금", "토", "일"]
    var selectedDays: [String] = [] // 선택된 요일 리스트
    
    private let contentScrollView = UIScrollView().then {
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = .white
    }
    
    let backBtn = UIButton().then {
        $0.setImage(UIImage(named: "back"), for: .normal)
        $0.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    }
    
    let titleLabel = UILabel().then {
        $0.text = "루틴 정보 입력"
        $0.textColor = UIColor.font.primary
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 24)
        $0.numberOfLines = 1
    }
    
    let descriptionLabel = UILabel().then {
        $0.text = "꾸준히 실천할 루틴의 카티고리와 이름 정보를 입력해 주세요."
        $0.textColor = UIColor.font.secondary
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.regular.rawValue, size: 14)
        $0.numberOfLines = 1
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
    
    let textField = UITextField().then {
        $0.placeholder = ""
        $0.attributedPlaceholder = NSAttributedString(
            string: "",
            attributes: [.foregroundColor: UIColor(156, 163, 175, 1)]
        )
        $0.textColor = .black
        $0.backgroundColor = UIColor(243, 244, 246, 1)
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 0
        
        $0.autocorrectionType = .no                     // 자동 수정 활성화 여부
        $0.spellCheckingType = .no                      // 맞춤법 검사 활성화 여부
        $0.autocapitalizationType = .none               // 자동 대문자 활성화 여부
        $0.clearButtonMode = .always                    // 입력내용 한번에 지우는 x버튼(오른쪽)
        $0.clearsOnBeginEditing = false                 // 편집 시 기존 텍스트필드값 제거?
        $0.returnKeyType = .done                        // 키보드 엔터키(return, done... )
    }
    
    let helperLabel = UILabel().then {
        $0.text = "루틴 이름은 50자 이내로 입력해 주세요"
        $0.textColor = UIColor(107, 114, 128, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.regular.rawValue, size: 12)
        $0.numberOfLines = 1
    }
    
    let maxCountLabel = UILabel().then {
        $0.text = "/50"
        $0.textColor = UIColor(107, 114, 128, 1)
        $0.textAlignment = .right
        $0.font = UIFont(name: Font.regular.rawValue, size: 12)
        $0.numberOfLines = 1
    }
    
    let currentCountLabel = UILabel().then {
        $0.text = "0"
        $0.textColor = UIColor(3, 7, 18, 1)
        $0.textAlignment = .right
        $0.font = UIFont(name: Font.regular.rawValue, size: 12)
        $0.numberOfLines = 1
    }
    
    let daySetTitleLabel = UILabel().then {
        $0.text = "실천할 요일 설정"
        $0.textColor = UIColor(3, 7, 18, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 24)
        $0.numberOfLines = 0
    }
    
    let daySetDescriptionLabel = UILabel().then {
        $0.text = "꾸준히 실천할 요일을 설정해 주세요."
        $0.textColor = UIColor(107, 114, 128, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.regular.rawValue, size: 14)
        $0.numberOfLines = 0
    }
    
    let dayStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.backgroundColor = .clear
    }
    
    let termSetTitleLabel = UILabel().then {
        $0.text = "실천 기간 설정"
        $0.textColor = UIColor(3, 7, 18, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 24)
        $0.numberOfLines = 0
    }
    
    let termSetDescriptionLabel = UILabel().then {
        $0.text = "목표 기간을 설정해 주세요"
        $0.textColor = UIColor(107, 114, 128, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.regular.rawValue, size: 14)
        $0.numberOfLines = 0
    }
    
    let slider = UISlider().then {
        $0.value = 2
        $0.minimumValue = 1
        $0.maximumValue = 7
        $0.isContinuous = true
        $0.minimumTrackTintColor = UIColor.fill.brand
        $0.maximumTrackTintColor = UIColor.background.secondary
        $0.thumbTintColor = UIColor.white // 핸들 색상
        $0.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
    }
    
    let sliderStartLabel = UILabel().then {
        $0.text = "최소 1개월"
        $0.textColor = UIColor.font.secondary
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 14)
        $0.numberOfLines = 0
    }
    
    let sliderEndLabel = UILabel().then {
        $0.text = "최소 6개월"
        $0.textColor = UIColor.font.secondary
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 14)
        $0.numberOfLines = 0
    }
    
    let completeBtn = UIButton().then {
        $0.backgroundColor = UIColor(31, 41, 55, 1)
        $0.layer.cornerRadius = 16
        $0.setTitle("완료", for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.setTitleColor(.white, for: .normal)
        $0.addTarget(self, action: #selector(tapCompleteBtn), for: .touchUpInside)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setGesture()
        setLayout()
        setupCollectionView()
        setDaySetView()
        addObserver()
        setTextField()
        selectFirstCategory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 스와이프 뒤로 가기 제스처 다시 활성화
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateContentViewHeight()
    }
    
    func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false  // 다른 터치 이벤트에도 영향을 주지 않도록 설정
        contentScrollView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - API 요청
    func requestSaveAIData(jsonBody: [String : Any]) {
        let url = NetworkManager.shared.getRequestURL(api: "/api/recommend/\(id!)" )

        NetworkManager.shared.sendRequest(url: url, method: "POST", jsonBody: jsonBody) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.GoalSettingResponse.self, from: data)
                    if decodedResponse.message == "created" {
                        NotificationCenter.default.post(name: Notification.Name("AddRoutine"), object: nil, userInfo: ["id" : self.id!])
                            
                        // completion 지정
                        CATransaction.begin()
                        CATransaction.setCompletionBlock {
                            // 이전 화면으로 돌아간 후에 toast message 보여줌
                            self.showToastAfterPop()
                        }
                        self.navigationController?.popViewController(animated: true)
                        CATransaction.commit()
                    }
                    else {
                        print("서버 연결 오류")
                        ErrorViewController.showErrorPage(viewController: self)
                    }
                } catch {
                    print("JSON 디코딩 오류: \(error)")
                    ErrorViewController.showErrorPage(viewController: self)
                }
            case .failure(let error):
                // 요청이 실패한 경우
                print("API 요청 실패: \(error.localizedDescription)")
                ErrorViewController.showErrorPage(viewController: self)
            }
        }
    }
    
    func requestSaveCustomData(param: JSONModel.CustomGoalSetting) {
        let url = NetworkManager.shared.getRequestURL(api: "/api/routine" )
        
        guard let jsonData = try? JSONEncoder().encode(param),
              let param = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else { return }
                
        NetworkManager.shared.requestAPI(url: url, method: .post, encoding: JSONEncoding.default , param: param) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.GoalSettingResponse.self, from: data)
                    if decodedResponse.message == "created" {
                        // completion 지정
                        CATransaction.begin()
                        CATransaction.setCompletionBlock {
                            // 이전 화면으로 돌아간 후에 toast message 보여줌
                            self.showToastAfterPop()
                        }
                        self.navigationController?.popViewController(animated: true)
                        CATransaction.commit()
                    }
                    else {
                        print("서버 연결 오류")
                        ErrorViewController.showErrorPage(viewController: self)
                    }
                } catch {
                    print("JSON 디코딩 오류: \(error)")
                    ErrorViewController.showErrorPage(viewController: self)
                }
            case .failure(let error):
                // 요청이 실패한 경우
                print("API 요청 실패: \(error.localizedDescription)")
                ErrorViewController.showErrorPage(viewController: self)
            }
        }
    }
    
    // MARK: - Observer Set
    func addObserver() {
        // 실시간 입력 이벤트 감지
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - 슬라이더 관련 함수
    @objc private func sliderChanged(_ sender: UISlider) {
        // 1개월 단위로 값 보정
        let roundedValue = round(sender.value)
        sender.value = roundedValue
        
        if sender.value <= 2.0 {
            sender.value = 2
        }
        
        if vibrationValue != Double(roundedValue) {
            vibrationValue = Double(roundedValue)
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
    
    // MARK: - 글자입력 관련 함수
    // 현재 텍스트에서 글자 수 계산
    // 최대 글자 수 초과 시 마지막 글자 삭제
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        let characterCount = text.countText()
        currentCountLabel.text = "\(characterCount)"
    
        if characterCount > maxTextCount {
            // 50자 초과한 글자는 바로 삭제
            textField.deleteBackward()
        }
        else if characterCount == maxTextCount {
            helperLabel.text = "50자 이내로 입력해주세요"
            helperLabel.textColor = UIColor(234, 88, 12, 1)
            currentCountLabel.textColor = UIColor(234, 88, 12, 1)
        }
        else if characterCount < maxTextCount {
            helperLabel.text = "루틴 이름은 50자 이내로 입력해 주세요"
            helperLabel.textColor = UIColor(107, 114, 128, 1)
            currentCountLabel.textColor = UIColor(3, 7, 18, 1)
        }
    }
    
    func setTextField() {
        textField.delegate = self
        textField.addLeftPadding() // textfield 왼쪽에 padding 추가
        
        // 기본적으로 정해지는 루틴 이름 글자수 표기
        let text = textField.text ?? ""
        let characterCount = text.countText()
        currentCountLabel.text = "\(characterCount)"
    }
    
    
    // MARK: - 카테고리 관련 함수
    // 처음 0번째 카테고리 셀을 선택된 상태로 설정
    // 처음에 카테고리를 클릭하지 않아도 첫번재 카테고리가 자동으로 선택되어 있게 함
    func selectFirstCategory() {
        let firstIndexPath = IndexPath(item: 0, section: 0)
        categoryCollectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .left)
    }
    
    // MARK: - 레이아웃, UI 관련 함수
    
    // tableView의 콘텐츠 높이에 따라 contentView의 높이를 동적으로 조정
    func updateContentViewHeight() {
        self.view.layoutIfNeeded() // 레이아웃 강제 업데이트
        var contentHeight: CGFloat!
        
        if isRecommendedData {
            contentHeight = 549
        }
        else {
            contentHeight = 691
        }
        
        // 스크롤뷰 콘텐츠 최소 길이를 기기 화면 크기로 지정
        let screenHeight = view.safeAreaLayoutGuide.layoutFrame.height
        if contentHeight < screenHeight {
            contentHeight = screenHeight
        }
        
        contentScrollView.contentSize = CGSize(width: contentScrollView.frame.width, height: contentHeight)
        contentView.snp.updateConstraints {
            $0.height.equalTo(contentHeight)
        }
    }
    
    // 요일 버튼 생성 후 stack 에 add
    func setDaySetView() {
        for day in days {
            let button = createDayButton(title: day)
            dayStackView.addArrangedSubview(button)
        }
    }
    
    // 요일 버튼 생성
    private func createDayButton(title: String) -> UIButton {
        let button = UIButton().then {
            $0.setTitle(title, for: .normal)
            $0.setTitleColor(UIColor(3, 7, 18, 1), for: .normal)
            
            $0.titleLabel?.font = UIFont(name: Font.medium.rawValue, size: 14)
            $0.setTitleColor(UIColor(3, 7, 18, 1), for: .normal)
            
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor(229, 231, 235, 1).cgColor
            $0.layer.cornerRadius = 6
            $0.backgroundColor = .white
            $0.tag = days.firstIndex(of: title) ?? 0
            $0.addTarget(self, action: #selector(tapDayBtn), for: .touchUpInside)
        }
        
        button.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        return button
    }
    
    @objc func tapDayBtn(_ sender: UIButton) {
        guard let dayString = sender.currentTitle else { return }

        if sender.backgroundColor == .white {
            sender.backgroundColor = UIColor(224, 231, 255, 1)
            sender.layer.borderColor = UIColor(129, 140, 248, 1).cgColor
            addDay(dayString: dayString)
        }
        else {
            sender.backgroundColor = .white
            sender.layer.borderColor = UIColor(229, 231, 235, 1).cgColor
            removeDay(dayString: dayString)
        }
    }
    
    @objc func tapCompleteBtn() {

        if textField.text == "" {
            showToast(view: view, message: "루틴 이름을 입력해 주세요", imageName: "warning-mark", withDuration: 0.5, delay: 1.5)
        }
        else if selectedDays.isEmpty {
            showToast(view: view, message: "실천할 요일을 설정해 주세요", imageName: "warning-mark", withDuration: 0.5, delay: 1.5)
        }
        else {
            selectedDays = selectedDays.map{
                switch $0 {
                case "월" : return "MON"
                case "화" : return "TUE"
                case "수" : return "WED"
                case "목" : return "THU"
                case "금" : return "FRI"
                case "토" : return "SAT"
                case "일" : return "SUN"
                default: return "MON"
                }
            }

            let title = textField.text ?? ""
            let description = routineDescription ?? ""
            let categoryText = category ?? "HOUSE"
            
            // 추천된 루틴 저장
            if isRecommendedData {
                let jsonBody: [String: Any] = [
                    "title": title ,
                    "description": description,
                    "weekList": selectedDays,
                    "category": categoryText,
                    "month": Int(slider.value - 1)
                ]
                requestSaveAIData(jsonBody: jsonBody)
            }
            
            // 커스텀 루틴 직접 저장
            else {
                let param = JSONModel.CustomGoalSetting(title: title, description: description, weekList: selectedDays, category: categoryText, month: Int(slider.value - 1))
                requestSaveCustomData(param: param)
            }
        }
    }
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func showToastAfterPop() {
        showToast(view: self.preViewController!.view!, message: "루틴 설정 완료", imageName: "Icon-Circle-Check", withDuration: 0.5, delay: 1.5)
    }
    
    func addDay(dayString: String) {
        selectedDays.append(dayString)
    }
    
    func removeDay(dayString: String) {
        if let index = selectedDays.firstIndex(of: dayString) {
            selectedDays.remove(at: index)
        }
    }
    
    private func setupCollectionView() {
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
    }
    
    func setUI() {
        view.backgroundColor = .white
        
        DispatchQueue.main.async {
            self.slider.value = 2  // 슬라이더 초기 위치를 2로 설정
        }
        
        if isRecommendedData {
            guard let routineName = routineName else { return }
            textField.text = routineName
            textField.placeholder = routineName
            textField.attributedPlaceholder = NSAttributedString( string: routineName )
        }
        else {
            textField.placeholder = "루틴 이름을 입력해 주세요"
        }
    }
    
    func setLayout() {
        [contentScrollView].forEach({ view.addSubview($0) })
        [contentView].forEach({ contentScrollView.addSubview($0) })
        [backBtn, textField, helperLabel, maxCountLabel, currentCountLabel, daySetTitleLabel, daySetDescriptionLabel, dayStackView, termSetTitleLabel, termSetDescriptionLabel, slider, sliderStartLabel, sliderEndLabel, completeBtn].forEach({ contentView.addSubview($0) })
        
        if !isRecommendedData {
            [titleLabel, descriptionLabel, categoryCollectionView].forEach({ contentView.addSubview($0) })
            
            self.titleLabel.snp.makeConstraints {
                $0.left.right.equalToSuperview().inset(20)
                $0.top.equalTo(backBtn.snp.bottom).offset(28)
            }
            
            self.descriptionLabel.snp.makeConstraints {
                $0.left.right.equalToSuperview().inset(20)
                $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            }
            
            self.categoryCollectionView.snp.makeConstraints {
                $0.left.right.equalToSuperview().inset(20)
                $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
                $0.height.equalTo(38)
            }
            
            self.textField.snp.makeConstraints {
                $0.left.right.equalToSuperview().inset(20)
                $0.top.equalTo(categoryCollectionView.snp.bottom).offset(16)
                $0.height.equalTo(48)
            }
        }
        else {
            self.textField.snp.makeConstraints {
                $0.left.right.equalToSuperview().inset(20)
                $0.top.equalTo(backBtn.snp.bottom).offset(28)
                $0.height.equalTo(48)
            }
        }
        
        self.contentScrollView.snp.makeConstraints {
            $0.top.bottom.right.left.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.contentView.snp.makeConstraints {
            $0.top.bottom.right.left.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        self.backBtn.snp.makeConstraints {
            $0.top.left.equalToSuperview().inset(20)
            $0.width.height.equalTo(24)
        }
        
        self.helperLabel.snp.makeConstraints {
            $0.left.equalToSuperview().inset(28)
            $0.top.equalTo(textField.snp.bottom).offset(7)
        }
        
        self.maxCountLabel.snp.makeConstraints {
            $0.right.equalToSuperview().inset(28)
            $0.top.equalTo(textField.snp.bottom).offset(7)
        }
        
        self.currentCountLabel.snp.makeConstraints {
            $0.right.equalTo(maxCountLabel.snp.left)
            $0.top.equalTo(textField.snp.bottom).offset(7)
        }
        
        self.daySetTitleLabel.snp.makeConstraints {
            $0.top.equalTo(helperLabel.snp.bottom).offset(48)
            $0.right.left.equalToSuperview().inset(20)
        }
        
        self.daySetDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(daySetTitleLabel.snp.bottom).offset(8)
            $0.right.left.equalToSuperview().inset(20)
        }
        
        self.dayStackView.snp.makeConstraints {
            $0.top.equalTo(daySetDescriptionLabel.snp.bottom).offset(20)
            $0.left.equalToSuperview().inset(20)
            $0.right.equalToSuperview().inset(27)
        }
        
        self.termSetTitleLabel.snp.makeConstraints {
            $0.top.equalTo(dayStackView.snp.bottom).offset(48)
            $0.right.left.equalToSuperview().inset(20)
        }
        
        self.termSetDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(termSetTitleLabel.snp.bottom).offset(8)
            $0.right.left.equalToSuperview().inset(20)
        }
        
        self.slider.snp.makeConstraints {
            $0.top.equalTo(termSetDescriptionLabel.snp.bottom).offset(32)
            $0.right.left.equalToSuperview().inset(20)
        }
        
        self.sliderStartLabel.snp.makeConstraints {
            $0.top.equalTo(slider.snp.bottom).offset(20)
            $0.left.equalToSuperview().inset(20)
        }
        
        self.sliderEndLabel.snp.makeConstraints {
            $0.top.equalTo(slider.snp.bottom).offset(20)
            $0.right.equalToSuperview().inset(20)
        }
        
        self.completeBtn.snp.makeConstraints {
            $0.right.left.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(56)
        }
    }
}

extension GoalSettingViewController: UITextFieldDelegate {
    
    // 완료버튼 누를시 키보드 내려감
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // 한글자 입력/제거 할때마다 호출
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // 최대 글자수 도달하더라도 backspace는 허용
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        
        let text = textField.text ?? ""
        let textCount = text.countText()

        return true
    }
}

extension GoalSettingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // 스와이프 제스처 허용
    }
}

extension GoalSettingViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }

        if indexPath.item == 0 {
            cell.isClicked = true
        }
        
        cell.setContent(category: categoryList[indexPath.row])
        
        return cell
    }

    // 셀 크기 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = categoryList[indexPath.row]
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
        switch categoryList[indexPath.row] {
        case "주거":
            selectedCategoryIndex = 0
            category = categoryServerString["주거"]
        case "소비":
            selectedCategoryIndex = 1
            category = categoryServerString["소비"]
        case "여가생활":
            selectedCategoryIndex = 2
            category = categoryServerString["여가생활"]
        case "자기관리":
            selectedCategoryIndex = 3
            category = categoryServerString["자기관리"]
        default: break
        }
        
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
