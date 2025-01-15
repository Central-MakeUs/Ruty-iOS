//
//  SignUpAgreeViewController.swift
//  Ruty
//
//  Created by 정성희 on 1/9/25.
//

import UIKit
import SnapKit
import Then
import SafariServices

class SignUpAgreeViewController: UIViewController {
    
    let navigationView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let backBtn = UIButton().then {
        $0.setImage(UIImage(named: "back"), for: .normal)
    }
    
    private let progressBarView = ProgressBarView().then {
        $0.layer.cornerRadius = 4
    }
    
    let titleLabel1 = UILabel().then {
        $0.text = "이용약관에"
        $0.textColor = UIColor(3, 7, 18, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 24)
        $0.numberOfLines = 1
    }
    
    let titleLabel2 = UILabel().then {
        $0.text = "동의해 주세요"
        $0.textColor = UIColor(3, 7, 18, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 24)
        $0.numberOfLines = 1
    }
    
    let descriptionLabel = UILabel().then {
        $0.text = "원활한 서비스 이용을 위해 아래 약관에 동의해주세요"
        $0.textColor = UIColor(107, 114, 128, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.regular.rawValue, size: 14)
        $0.numberOfLines = 1
    }
    
    let agreeContainer = UIView().then {
        $0.backgroundColor = UIColor(249, 250, 251, 1)
        $0.layer.cornerRadius = 8
    }
    
    let agreeAllViewBtn = UIView().then {
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = true
    }
    
    let agreeAllcheckImage = UIImageView().then {
        $0.image = UIImage(named: "checkOff")
    }
    
    let agreeAllDescription = UILabel().then {
        $0.text = "전체 동의하기"
        $0.textColor = UIColor(3, 7, 18, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 14)
        $0.numberOfLines = 1
    }
    
    let agreeAllLine = UIView().then {
        $0.backgroundColor = UIColor(229, 231, 235, 1)
    }
    
    // 필수 옵션
    let agreeRequiredView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let agreeRequiredBtn = UIButton().then {
        $0.setImage(UIImage(named: "selectOff"), for: .normal)
        //$0.setImage(UIImage(named: "selectOn"), for: .selected)
    }
    
    let agreeRequiredDescription = UILabel().then {
        $0.text = "[필수] 루티 이용약관 및 개인정보 수집·이용 동의"
        $0.font = UIFont(name: Font.regular.rawValue, size: 12)
        $0.textColor = UIColor(3, 7, 18, 1)
        $0.isUserInteractionEnabled = true
    }
    
    
    // 선택 옵션
    let agreeOptionalView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let agreeOptionalBtn = UIButton().then {
        $0.setImage(UIImage(named: "selectOff"), for: .normal)
    }
    
    let agreeOptionalDescription = UILabel().then {
        $0.text = "[선택] 마케팅 활용 및 광고성 정보 수신 동의에 동의"
        $0.font = UIFont(name: Font.regular.rawValue, size: 12)
        $0.textColor = UIColor(3, 7, 18, 1)
        $0.isUserInteractionEnabled = true
    }
    
    let moveNextPageBtn = UIButton().then {
        $0.backgroundColor = UIColor(31, 41, 55, 1)
        $0.layer.cornerRadius = 16
        $0.setTitle("다음으로", for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.setTitleColor(.white, for: .normal)
    }
    
    var isAllAgree = false {
        didSet {
            if isAllAgree == true {
                agreeAllcheckImage.image = UIImage(named: "checkOn")
            }
            else {
                agreeAllcheckImage.image = UIImage(named: "checkOff")
            }
        }
    }
    
    // 해당 변수가 true 일때만 다음 페이지로 이동이 가능
    var isRequiredAgree = false {
        didSet {
            if isRequiredAgree == true {
                agreeRequiredBtn.setImage(UIImage(named: "selectOn"), for: .normal)
                
                // 다음 페이지 버튼 활성화
                moveNextPageBtn.backgroundColor = UIColor(31, 41, 55, 1)
                moveNextPageBtn.setTitleColor(.white, for: .normal)
            }
            else {
                agreeRequiredBtn.setImage(UIImage(named: "selectOff"), for: .normal)
            }
            
            checkAndUpdateAllAgree()
        }
    }
    
    var isOptionalAgree = false {
        didSet {
            if isOptionalAgree == true {
                agreeOptionalBtn.setImage(UIImage(named: "selectOn"), for: .normal)
            }
            else {
                agreeOptionalBtn.setImage(UIImage(named: "selectOff"), for: .normal)
            }
            
            checkAndUpdateAllAgree()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setLayout()
        addTargetToLabel()
        addTargetToBtn()
        self.progressBarView.ratio = 0.0
    }
    
    func addTargetToLabel() {
        setLinkToLabel(label: agreeRequiredDescription, textToLink: "이용약관")
        setLinkToLabel(label: agreeOptionalDescription, textToLink: "마케팅 활용 및 광고성 정보 수신 동의")
    }
    
    // MARK: - layout
    func setLayout() {
        [navigationView, titleLabel1, titleLabel2, descriptionLabel, agreeContainer, moveNextPageBtn].forEach({ view.addSubview($0) })
        [backBtn, progressBarView].forEach({ navigationView.addSubview($0) })
        [agreeAllViewBtn, agreeRequiredView, agreeOptionalView].forEach({ agreeContainer.addSubview($0) })
        [agreeAllcheckImage, agreeAllDescription, agreeAllLine].forEach({ agreeAllViewBtn.addSubview($0) })
        [agreeRequiredBtn, agreeRequiredDescription].forEach({ agreeRequiredView.addSubview($0) })
        [agreeOptionalBtn, agreeOptionalDescription].forEach({ agreeOptionalView.addSubview($0) })
        
        self.moveNextPageBtn.snp.makeConstraints {
            $0.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(56)
        }
        
        self.navigationView.snp.makeConstraints {
            $0.top.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(24)
        }
        
        self.backBtn.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        self.progressBarView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(40)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(8)
        }
        
        self.titleLabel1.snp.makeConstraints({
            $0.top.equalTo(progressBarView).offset(48)
            $0.leading.trailing.equalToSuperview().inset(20)
        })
        
        self.titleLabel2.snp.makeConstraints({
            $0.top.equalTo(titleLabel1.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
        })
        
        self.descriptionLabel.snp.makeConstraints({
            $0.top.equalTo(titleLabel2.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(20)
        })
        
        self.agreeContainer.snp.makeConstraints {
            $0.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(40)
            $0.height.equalTo(164)
        }
        
        self.agreeAllViewBtn.snp.makeConstraints {
            $0.left.right.equalTo(agreeContainer).inset(16)
            $0.top.equalTo(agreeContainer).offset(20)
            $0.height.equalTo(28)
        }
        
        self.agreeAllcheckImage.snp.makeConstraints {
            $0.left.top.bottom.equalTo(agreeAllViewBtn)
            $0.width.equalTo(28)
        }
        
        self.agreeAllDescription.snp.makeConstraints {
            $0.left.equalTo(agreeAllcheckImage.snp.right).offset(8)
            $0.centerY.equalToSuperview()
        }
        
        self.agreeAllLine.snp.makeConstraints {
            $0.left.right.equalTo(agreeContainer).inset(16)
            $0.top.equalTo(agreeAllViewBtn.snp.bottom).offset(20)
            $0.height.equalTo(1)
        }
        
        
        
        // MARK: - 필수 동의란 관련
        self.agreeRequiredView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalTo(agreeAllLine.snp.bottom).offset(20)
            $0.height.equalTo(20)
        }
        
        self.agreeRequiredBtn.snp.makeConstraints {
            $0.left.equalToSuperview().offset(4)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(20)
        }
        
        self.agreeRequiredDescription.snp.makeConstraints {
            $0.left.equalTo(agreeRequiredBtn.snp.right).offset(8)
            $0.centerY.equalToSuperview()
        }
        
        
        // MARK: - 선택 동의란 관련
        self.agreeOptionalView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalTo(agreeAllLine.snp.bottom).offset(56)
            $0.height.equalTo(20)
        }
        
        self.agreeOptionalBtn.snp.makeConstraints {
            $0.left.equalToSuperview().offset(4)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(20)
        }
        
        self.agreeOptionalDescription.snp.makeConstraints {
            $0.left.equalTo(agreeRequiredBtn.snp.right).offset(8)
            $0.centerY.equalToSuperview()
        }
    }
    
    func setLinkToLabel(label: UILabel, textToLink: String) {
        guard let text = label.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: UIColor(67, 56, 202, 1), range: (text as NSString).range(of: textToLink))
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: (text as NSString).range(of: textToLink))
        
        
        if textToLink == "이용약관"{
            label.tag = 1
            attributedString.addAttribute(.foregroundColor, value: UIColor(67, 56, 202, 1), range: (text as NSString).range(of: "개인정보 수집·이용"))
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: (text as NSString).range(of: "개인정보 수집·이용"))
        }
        else if textToLink == "마케팅 활용 및 광고성 정보 수신 동의" {
            label.tag = 2
        }
        
        label.attributedText = attributedString
        
        // Tap Gesture 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        label.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
              let text = label.text else { return }
        
        if label.tag == 1 {
            let tapLocation = gesture.location(in: label)
            if let index = characterIndex(at: tapLocation, in: label),
               let range = (text as NSString).range(of: "이용약관").toRange(),
               range.contains(index) {
                print("이용약관 클릭됨!")
                // 원하는 함수 호출
                let pageURL = NSURL(string: "https://www.naver.com/")
                let infoView: SFSafariViewController = SFSafariViewController(url: pageURL as! URL)
                self.present(infoView, animated: true, completion: nil)
            }
            if let index = characterIndex(at: tapLocation, in: label),
               let range = (text as NSString).range(of: "개인정보 수집·이용").toRange(),
               range.contains(index) {
                print("개인정보 클릭됨!")
                // 원하는 함수 호출
                let pageURL = NSURL(string: "https://www.naver.com/")
                let infoView: SFSafariViewController = SFSafariViewController(url: pageURL as! URL)
                self.present(infoView, animated: true, completion: nil)
            }
        }
        else if label.tag == 2 {
            let tapLocation = gesture.location(in: label)
            if let index = characterIndex(at: tapLocation, in: label),
               let range = (text as NSString).range(of: "마케팅 활용 및 광고성 정보 수신 동의").toRange(),
               range.contains(index) {
                print("마케팅 클릭됨!")
                // 원하는 함수 호출
                // 원하는 함수 호출
                let pageURL = NSURL(string: "https://www.naver.com/")
                let infoView: SFSafariViewController = SFSafariViewController(url: pageURL as! URL)
                self.present(infoView, animated: true, completion: nil)
            }
        }
    }
    
    func characterIndex(at point: CGPoint, in label: UILabel) -> Int? {
        guard let attributedText = label.attributedText else { return nil }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let location = CGPoint(x: point.x - label.bounds.origin.x, y: point.y - label.bounds.origin.y)
        let glyphIndex = layoutManager.glyphIndex(for: location, in: textContainer)
        
        return layoutManager.characterIndexForGlyph(at: glyphIndex)
    }
    
    // MARK: - 동의 버튼 로직
    
    // 선택, 필수 동의 클릭 시 전체 동의하기 활성화 여부 업데이트
    func checkAndUpdateAllAgree() {
        if isOptionalAgree == true && isRequiredAgree == true {
            isAllAgree = true
        }
        else if isOptionalAgree == false || isRequiredAgree == false {
            isAllAgree = false
        }
    }
    
    func addTargetToBtn() {
        var tapGesture = UITapGestureRecognizer(target: self, action: #selector(goBack))
        backBtn.addGestureRecognizer(tapGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAgreeAllViewBtn))
        agreeAllViewBtn.addGestureRecognizer(tapGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAgreeRequiredBtn))
        agreeRequiredBtn.addGestureRecognizer(tapGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAgreeOptionalBtn))
        agreeOptionalBtn.addGestureRecognizer(tapGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapNextPageBtn))
        moveNextPageBtn.addGestureRecognizer(tapGesture)
    }
    
    @objc func goBack() {
        self.dismiss(animated: false)
    }
    
    @objc func tapAgreeAllViewBtn() {
        if isAllAgree == false {
            isRequiredAgree = true
            isOptionalAgree = true
        }
        else {
            isRequiredAgree = false
            isOptionalAgree = false
        }
    }

    @objc func tapAgreeRequiredBtn() {
        isRequiredAgree = !isRequiredAgree
    }
    
    @objc func tapAgreeOptionalBtn() {
        isOptionalAgree = !isOptionalAgree
    }
    
    @objc func tapNextPageBtn() {
        if isRequiredAgree {
            print("다음 페이지 이동")
            let firstVC = SignUpWriteNameViewController()
            firstVC.modalPresentationStyle = .fullScreen
            self.present(firstVC, animated: false, completion: nil)
        }
        else {
            showToast(view: view, "필수 약관에 동의해주세요", withDuration: 2.0, delay: 1.5)
        }
    }
}
