//
//  OnBoardingMainViewController.swift
//  Ruty
//
//  Created by 정성희 on 1/21/25.
//

import UIKit

class OnBoardingMainViewController: UIViewController {
    
    var goalData : JSONModel.AllGoal?
    
    private let contentScrollView = UIScrollView().then {
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = .white
    }
    
    let navigationView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let backBtn = UIButton().then {
        $0.setImage(UIImage(named: "back"), for: .normal)
    }
    
    private let progressBarView = ProgressBarView().then {
        $0.layer.cornerRadius = 4
    }
    
    let titleLabel = UILabel().then {
        $0.text = "개선하고 싶은 점"
        $0.textColor = UIColor(3, 7, 18, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 24)
        $0.numberOfLines = 1
    }
    
    let descriptionLabel1 = UILabel().then {
        $0.text = "혼자 살면서 힘든점이나, 개선하고 싶은 점을"
        $0.textColor = UIColor(107, 114, 128, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.regular.rawValue, size: 14)
        $0.numberOfLines = 1
    }
    
    let descriptionLabel2 = UILabel().then {
        $0.text = "최소1개에서 최대 3개까지 입력해주세요"
        $0.textColor = UIColor(107, 114, 128, 1)
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.regular.rawValue, size: 14)
        $0.numberOfLines = 1
    }
    
    
    let completeBtn = UIButton().then {
        $0.backgroundColor = UIColor(31, 41, 55, 1)
        $0.layer.cornerRadius = 16
        $0.setTitle("완료", for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.setTitleColor(.white, for: .normal)
    }
    
    private let tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.separatorStyle = .singleLine
        $0.isScrollEnabled = false
    }
    
    var selectedCellCnt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 기본 Setting
        self.progressBarView.ratio = 0.3
        self.view.backgroundColor = .white
        addTarget()
        
        // table view func
        setupTableView()
        
        setLayout()
        
        // tableView의 팬 제스처를 contentScrollView로 전달
        // tableView 의 스크롤은 안되더라도 클릭 제스쳐는 작동하게함
        contentScrollView.panGestureRecognizer.require(toFail: tableView.panGestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 프로그래스 바 0.3 -> 0.6 변화 애니메이션
        self.progressBarView.ratio = 0.6
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentViewHeight()
    }
    
    // tableView의 콘텐츠 높이에 따라 contentView의 높이를 동적으로 조정
    func updateContentViewHeight() {
        let tableViewHeight = tableView.contentSize.height
        let contentHeight = tableViewHeight
                            + navigationView.frame.height
                            + titleLabel.frame.height
                            + descriptionLabel1.frame.height
                            + descriptionLabel2.frame.height
                            + 87 // 기타 고정된 간격

        // 스크롤뷰의 콘텐츠 크기 업데이트
        contentScrollView.contentSize = CGSize(width: contentScrollView.frame.width, height: contentHeight)
        
        contentView.snp.updateConstraints {
            $0.height.equalTo(contentHeight)
        }
    }
    
    func addTarget() {
        var tapGesture = UITapGestureRecognizer(target: self, action: #selector(goBack))
        backBtn.addGestureRecognizer(tapGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(goNextPage))
        completeBtn.addGestureRecognizer(tapGesture)
    }
    
    func setLayout() {
        [contentScrollView, completeBtn].forEach({ view.addSubview($0) })
        [contentView].forEach({ contentScrollView.addSubview($0) })
        [navigationView, titleLabel, descriptionLabel1, descriptionLabel2, tableView].forEach({ contentView.addSubview($0) })
        [backBtn, progressBarView].forEach({ navigationView.addSubview($0) })
        
        self.contentScrollView.snp.makeConstraints {
            $0.bottom.equalTo(completeBtn.snp.top).offset(-20)
            $0.top.right.left.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.contentView.snp.makeConstraints {
            $0.top.bottom.right.left.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        self.navigationView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview().inset(20)
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
        
        self.titleLabel.snp.makeConstraints({
            $0.top.equalTo(navigationView.snp.bottom).offset(28)
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
        
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel2.snp.bottom).offset(28)
            $0.bottom.left.right.equalToSuperview()
        }
        
        self.completeBtn.snp.makeConstraints {
            $0.right.left.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(56)
        }
    }
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func goNextPage() {
        // 0 개인 경우 통과 불가
        if selectedCellCnt == 0 {
            showToast(view: view, message: "최소 1개의 항목을 선택해 주세요", imageName: "warning-mark", withDuration: 0.5, delay: 1.5)
        }
        // 4개 이상인 경우 통과 불가
        else if selectedCellCnt >= 4 {
            showToast(view: view, message: "최대 3개까지만 선택이 가능해요", imageName: "warning-mark", withDuration: 0.5, delay: 1.5)
        }
        // 1~3 개인 경우 통과
        else {
            guard let isGuest = DataManager.shared.isGuest else { return }
            if isGuest {
                let popUpVC = PopUpViewController()
                popUpVC.modalPresentationStyle = .overFullScreen
                self.present(popUpVC, animated: true, completion: nil)
            }
            else {
                // GPT Prompt 전달
                RoutineDataProvider.shared.setGPTParam(prompt: getGPTPrompt())
                
                let secondVC = LoadingViewController()
                secondVC.modalPresentationStyle = .fullScreen
                self.present(secondVC, animated: true)
            }
        }
    }
    
    // 선택된 개선하고 싶은 점을 프롬프트 메시지로 변환하여 반환
    private func getGPTPrompt() -> String {
        var prompt = ""
        
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            
            guard let cell = tableView.cellForRow(at: indexPath) as? ImproveSelectTableViewCell else { return "null" }
            
            if cell.isChecked == true {
                if prompt == "" {
                    prompt += cell.content.text ?? "null"
                }
                else {
                    prompt += ", " + (cell.content.text ?? "null")
                }
            }
        }
        
        print("prompt: \(prompt)")
        return prompt
    }
    
    // MARK: - TableView Func
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none // cell 라인 없애기
        tableView.register(ImproveSelectTableViewCell.self, forCellReuseIdentifier: ImproveSelectTableViewCell.identifier)
    }
}


extension OnBoardingMainViewController : UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (goalData?.data.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImproveSelectTableViewCell.identifier, for: indexPath) as? ImproveSelectTableViewCell, let goalData = goalData else {
            return UITableViewCell()
        }

        let item = goalData.data[indexPath.row]
        cell.setContent(text: item.content, category: item.category )
        
        // cell 클릭시 보이게 되는 회색 배경색 제거
        let background = UIView()
        background.backgroundColor = .clear
        cell.selectedBackgroundView = background
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 클릭한 cell 에 접근
        if let selectedCell = tableView.cellForRow(at: indexPath) as? ImproveSelectTableViewCell {
            selectedCell.tapCell()
        }
        
        // cell 선택 개수 카운트
        countSelectedCell()
        
        // cell 선택 최대 개수 넘는지 체크하는 함수
        checkMaxSelectedCellCnt()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // cell 선택 최대 개수 넘는지 체크하는 함수
    func checkMaxSelectedCellCnt() {
        if selectedCellCnt >= 4 {
            showToast(view: view, message: "최대 3개까지만 선택이 가능해요", imageName: "warning-mark", withDuration: 0.5, delay: 1.5)
        }
    }
    
    // 현재 선택된 cell 총 개수 반환
    func countSelectedCell() {
        var selectedCnt = 0
        
        // 모든 셀 순회
        for visibleIndexPath in tableView.indexPathsForVisibleRows ?? [] {
            if let cell = tableView.cellForRow(at: visibleIndexPath) as? ImproveSelectTableViewCell {
                if cell.isChecked == true { selectedCnt += 1 }
            }
        }
        selectedCellCnt = selectedCnt
    }
}
