//
//  GoalSettingViewController.swift
//  Ruty
//
//  Created by 정성희 on 2/3/25.
//

import UIKit

class GoalSettingViewController: UIViewController {
    
    var routineViewController: RoutineViewController?
    
    var id: Int?
    var category: String?
    var routineDescription: String?
    var routineName: String?
    
    let maxTextCount = 50
    
    let days = ["월", "화", "수", "목", "금", "토", "일"]
    var selectedDays: [String] = [] // 선택된 요일 리스트
    
    let backBtn = UIButton().then {
        $0.setImage(UIImage(named: "back"), for: .normal)
        $0.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    }
    
    let textField = UITextField().then {
        $0.placeholder = ""
        $0.attributedPlaceholder = NSAttributedString(
            string: "",
            attributes: [.foregroundColor: UIColor(156, 163, 175, 1)]
        )
        $0.textColor = .black
        //$0.borderStyle = .roundedRect
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
        setLayout()
        setDaySetView()
        addObserver()
        setTextField()
        
        DispatchQueue.main.async {
            self.slider.value = 2  // 슬라이더 초기 위치를 2로 설정
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 스와이프 뒤로 가기 제스처 다시 활성화
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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
        else {
            // 1개월 단위 이동 시 진동
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
    
    
    // MARK: - 레이아웃, UI 관련 함수
    
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
            $0.width.height.equalTo(40)
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
        if selectedDays.isEmpty {
            showToast(view: view, message: "실천할 요일을 설정해 주세요", imageName: "warning-mark", withDuration: 0.5, delay: 1.5)
        }
        else {
            let url = NetworkManager.shared.getRequestURL(api: "/api/recommend/\(id!)" )

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

            let jsonBody: [String: Any] = [
                "title": textField.text ?? "" ,
                "description": routineDescription ?? "",
                "weekList": selectedDays,
                "category": category ?? "HOUSE",
                "month": Int(slider.value - 1)
            ]
            
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
    }
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func showToastAfterPop() {
        showToast(view: self.routineViewController!.view!, message: "루틴 설정 완료", imageName: "Icon-Circle-Check", withDuration: 0.5, delay: 1.5)
    }
    
    func addDay(dayString: String) {
        selectedDays.append(dayString)
    }
    
    func removeDay(dayString: String) {
        if let index = selectedDays.firstIndex(of: dayString) {
            selectedDays.remove(at: index)
        }
    }
    
    func setUI() {
        guard let routineName = routineName else { return }
        view.backgroundColor = .white
        textField.text = routineName
        textField.placeholder = routineName
        textField.attributedPlaceholder = NSAttributedString( string: routineName )
    }
    
    func setLayout() {
        [backBtn, textField, helperLabel, maxCountLabel, currentCountLabel, daySetTitleLabel, daySetDescriptionLabel, dayStackView, termSetTitleLabel, termSetDescriptionLabel, slider, sliderStartLabel, sliderEndLabel, completeBtn].forEach({ view.addSubview($0) })
        
        self.backBtn.snp.makeConstraints {
            $0.top.left.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.width.height.equalTo(24)
        }
        
        self.textField.snp.makeConstraints {
            $0.left.right.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.top.equalTo(backBtn.snp.bottom).offset(28)
            $0.height.equalTo(48)
        }
        
        self.helperLabel.snp.makeConstraints {
            $0.left.equalTo(view.safeAreaLayoutGuide).inset(28)
            $0.top.equalTo(textField.snp.bottom).offset(7)
        }
        
        self.maxCountLabel.snp.makeConstraints {
            $0.right.equalTo(view.safeAreaLayoutGuide).inset(28)
            $0.top.equalTo(textField.snp.bottom).offset(7)
        }
        
        self.currentCountLabel.snp.makeConstraints {
            $0.right.equalTo(maxCountLabel.snp.left)
            $0.top.equalTo(textField.snp.bottom).offset(7)
        }
        
        self.daySetTitleLabel.snp.makeConstraints {
            $0.top.equalTo(helperLabel.snp.bottom).offset(48)
            $0.right.left.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        self.daySetDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(daySetTitleLabel.snp.bottom).offset(8)
            $0.right.left.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        self.dayStackView.snp.makeConstraints {
            $0.top.equalTo(daySetDescriptionLabel.snp.bottom).offset(20)
            $0.left.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.right.equalTo(view.safeAreaLayoutGuide).inset(27)
        }
        
        self.termSetTitleLabel.snp.makeConstraints {
            $0.top.equalTo(dayStackView.snp.bottom).offset(48)
            $0.right.left.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        self.termSetDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(termSetTitleLabel.snp.bottom).offset(8)
            $0.right.left.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        self.slider.snp.makeConstraints {
            $0.top.equalTo(termSetDescriptionLabel.snp.bottom).offset(32)
            $0.right.left.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        self.sliderStartLabel.snp.makeConstraints {
            $0.top.equalTo(slider.snp.bottom).offset(20)
            $0.left.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        self.sliderEndLabel.snp.makeConstraints {
            $0.top.equalTo(slider.snp.bottom).offset(20)
            $0.right.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        self.completeBtn.snp.makeConstraints {
            $0.right.left.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(56)
        }
    }
}

extension GoalSettingViewController: UITextFieldDelegate {
    // 키보드 외의 화면 누를 시 키보드 내려감
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
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
