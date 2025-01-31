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
        $0.backgroundColor = .red
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
    
    private let tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.separatorStyle = .singleLine
        $0.isScrollEnabled = false
    }
    
    let moveToMainBtn = UIButton().then {
        $0.backgroundColor = UIColor(31, 41, 55, 1)
        $0.layer.cornerRadius = 16
        $0.setTitle("메인 화면으로 이동", for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.setTitleColor(.white, for: .normal)
    }
    
    private var routinesData = [[Routine]]()
    
    
    var cntForCellLayout = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setupTableView()
        setLayout()
        
        // 실제는 아래 코드 주석빼고 실행
        routinesData = RoutineDataProvider.shared.loadRoutinesData()
        
        //디버깅용
//        routinesData = [[
//            Routine(title: "퇴근", description: "배", category: "HOUSE"),
//            Routine(title: "집에가고싶어요", description: "이정도 길이면 될까요 이정도 길이면 될까요 이정도 길이면 될까요?", category: "HOUSE"),
//            Routine(title: "퇴근 후 나를 위한 한 끼 만들기퇴근 후 나를 위한 한 끼 만들기근 후 나를 위한 한 끼 ", description: "배달 음식을 자주 시키는 이유 중 하나는 손쉬운 해결책을 찾는 것인데, 간단한 집밥을 만들어 먹는 습관을 들이면 배달 음식에 대한 의존도를 줄일 수 있습니다.", category: "HOUSE")]]
//        routinesData = [[Routine(title: "퇴근 후 나를 위한 한 끼 만들기", description: "배달 음식을 자주 시키는 이유 중 하나는 손쉬운 해결책을 찾는 것인데, 간단한 집밥을 만들어 먹는 습관을 들이면 배달 음식에 대한 의존도를 줄일 수 있습니다.", category: "HOUSE")]]
//        
        
        // tableView의 팬 제스처를 contentScrollView로 전달
        // tableView 의 스크롤은 안되더라도 클릭 제스쳐는 작동하게함
        contentScrollView.panGestureRecognizer.require(toFail: tableView.panGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //tableView.reloadData()
        print("view will appear")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("view did layout subviews")
        self.updateContentViewHeight()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view did appear")
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none // cell 라인 없애기
        tableView.register(RoutineCellTableViewCell.self, forCellReuseIdentifier: RoutineCellTableViewCell.identifier)
    }
    
    // tableView의 콘텐츠 높이에 따라 contentView의 높이를 동적으로 조정
    func updateContentViewHeight() {
        self.view.layoutIfNeeded() // 레이아웃 강제 업데이트
        tableView.sizeToFit()
        let tableViewHeight = tableView.contentSize.height
        print("tableViewHeight \(tableViewHeight)")
        let contentHeight = tableViewHeight
                            + titleLabel.frame.height
                            + descriptionLabel1.frame.height
                            + descriptionLabel2.frame.height
                            + 115 // 기타 고정된 간격
        print("contentHeight \(contentHeight)")
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
        [contentScrollView, moveToMainBtn].forEach({ view.addSubview($0) })
        [contentView].forEach({ contentScrollView.addSubview($0) })
        [titleLabel, descriptionLabel1, descriptionLabel2, tableView].forEach({ contentView.addSubview($0) })
        
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
        
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel2.snp.bottom).offset(28)
            $0.bottom.left.right.equalToSuperview()
        }
        
        self.moveToMainBtn.snp.makeConstraints {
            $0.right.left.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(56)
        }
    }
}

extension RoutineViewController : UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routinesData[0].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoutineCellTableViewCell.identifier, for: indexPath) as? RoutineCellTableViewCell else {
            return UITableViewCell()
        }
        let item = routinesData[0][indexPath.row]
        cell.setContent(routineName: item.title, description: item.description, markImage: "housing")
        
        // cell 클릭시 보이게 되는 회색 배경색 제거
        let background = UIView()
        background.backgroundColor = .clear
        cell.selectedBackgroundView = background
        
        cell.setupLayout()

        DispatchQueue.main.async {
            //self.updateContentViewHeight()
        }
        
        return cell
    }
    
    // cell 높이 동적으로 조절
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = routinesData[0][indexPath.row]
        
        let newHeight = estimateTextHeight(text: item.description, width: tableView.frame.width - 40, font: UIFont(name: Font.regular.rawValue, size: 14)!) + estimateTextHeight(text: item.title, width: tableView.frame.width - 40, font: UIFont(name: Font.semiBold.rawValue, size: 20)!)
        
        print("cell 높이 \(newHeight + 160)")
        
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
        print("Selected row: \(indexPath.row)")
           
        // 클릭한 cell 에 접근
        if let selectedCell = tableView.cellForRow(at: indexPath) as? RoutineCellTableViewCell {
            //selectedCell.tapCell()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension UILabel {
    var actualNumberOfLines: Int {
        let textHeight = self.sizeThatFits(CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
        let lineHeight = self.font.lineHeight
        return Int(textHeight / lineHeight)
    }
}
