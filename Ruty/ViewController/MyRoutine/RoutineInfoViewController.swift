//
//  RoutineInfoViewController.swift
//  Ruty
//
//  Created by 정성희 on 3/4/25.
//

import UIKit
import FSCalendar

class RoutineInfoViewController: UIViewController {

    private let topBackgroundView = UIView().then {
        $0.backgroundColor = UIColor.background.secondary
    }
    
    private let bottomBackgroundView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let contentScrollView = UIScrollView().then {
        $0.backgroundColor = UIColor.background.secondary
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = UIColor.background.secondary
    }
    
    private let backBtn = UIButton().then {
        $0.setImage(UIImage(named: "back"), for: .normal)
        $0.addTarget(self, action: #selector(moveToBackPage), for: .touchUpInside)
    }
    
    private let titleStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.backgroundColor = .clear
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "퇴근 후 나를 위한 한 끼 만들기"
        $0.textColor = UIColor(23, 23, 25, 1)
        $0.textAlignment = .center
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 20)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private let categoryMarkImage = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "housing")
    }
    
    private let dayStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
        $0.distribution = .equalCentering
    }
    
    private let dayLabel = UILabel().then {
        $0.text = "월, 화, 수, 목, 금, 일"
        $0.textAlignment = .center
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 12)
        $0.textColor = UIColor.font.secondary
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    private let dateLabel = UILabel().then {
        $0.text = "yyyy.MM.dd - yyyy.MM.dd"
        $0.textAlignment = .center
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 12)
        $0.textColor = UIColor.font.secondary
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    private let processRateBlock = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    private let processRateLabel = UILabel().then {
        $0.text = "달성률"
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.medium.rawValue, size: 14)
        $0.textColor = UIColor.font.secondary
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    private let processPercent = UILabel().then {
        $0.text = "N%"
        $0.textAlignment = .right
        $0.font = UIFont(name: Font.medium.rawValue, size: 14)
        $0.textColor = UIColor.font.secondary
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    private let progressBarView = ProgressBarView().then {
        $0.layer.cornerRadius = 4
    }
    
    private let processMarkImage = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "Icon-Circle-Check")
    }
    
    private let processHelperLabel = UILabel().then {
        $0.text = "연속 10회 수행 중!"
        $0.textAlignment = .left
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 14)
        $0.textColor = UIColor(23, 23, 25, 1)
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    var calendarView = FSCalendar()
    
    // 커스텀 헤더
    private let calendarHeaderStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 40
        $0.alignment = .center
        $0.distribution = .equalCentering
    }
    
    private let calendarPreMoveBtn = UIButton().then {
        $0.setImage(UIImage(named: "Icon-Chevron Left"), for: .normal)
        $0.addTarget(self, action: #selector(moveToPrev), for: .touchUpInside)
    }
    
    private let calendarNextMoveBtn = UIButton().then {
        $0.setImage(UIImage(named: "Icon-Chevron Right"), for: .normal)
        $0.addTarget(self, action: #selector(moveToNext), for: .touchUpInside)
    }
    
    private let monthLabel = UILabel().then {
        $0.text = "test"
        $0.textColor = .black
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textAlignment = .center
    }
    
    private var currentPage: Date = Date() // 달력을 이동할 때 기준이 되는 날짜
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월"
        return formatter
    }()
    
    private let calendarBar = UIView().then {
        $0.backgroundColor = UIColor.border.primary
    }
    
    private let calendarBackgroundView = UIView().then {
        $0.backgroundColor = .white
    }
    
    let completeBtn = UIButton().then {
        $0.backgroundColor = UIColor(31, 41, 55, 1)
        $0.layer.cornerRadius = 16
        $0.setTitle("포기하기", for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.setTitleColor(.white, for: .normal)
        $0.addTarget(self, action: #selector(tapCompleteBtn), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCalendarView()
        setUI()
        setLayout()
        setProcessBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleLabel.preferredMaxLayoutWidth = titleLabel.frame.width
        self.updateContentViewHeight()
        
        // 일요일만 빨갛게 설정
        for label in calendarView.calendarWeekdayView.weekdayLabels {
            if label.text == "일" {
                label.textColor = UIColor.font.warning
            } else {
                label.textColor = UIColor.font.tertiary
            }
        }
    }

    // MARK: - 캘린더
    func setCalendarView() {
        calendarView.delegate = self
        calendarView.dataSource = self
        
        calendarView.register(CalendarCell.self, forCellReuseIdentifier: CalendarCell.description())
        
        // 초기 달력 페이지 설정
        updateCalendarHeader()
        
        // 초기 날짜 지정
        calendarView.setCurrentPage(currentPage, animated: true)
        calendarView.select(Date())
            
        // 기존의 헤더 가림
        calendarView.appearance.headerTitleColor = .clear
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        calendarView.headerHeight = 88

        // 각종 설정
        calendarView.backgroundColor = .white
        calendarView.scrollEnabled = true
        calendarView.today = nil
        calendarView.scrollDirection = .horizontal
        calendarView.locale = Locale.init(identifier: "ko_KR")
        calendarView.scope = .month
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.appearance.titlePlaceholderColor = .clear // 기본 달력 날짜 투명화
        calendarView.appearance.selectionColor = .clear
        calendarView.appearance.weekdayFont = .boldSystemFont(ofSize: 14)
            
        calendarView.weekdayHeight = 36
        calendarView.placeholderType = .fillHeadTail
    }
    
    @objc func moveToPrev(_ sender: Any) {
        guard let newPage = Calendar.current.date(byAdding: .month, value: -1, to: currentPage) else { return }
        currentPage = newPage
        calendarView.setCurrentPage(currentPage, animated: true)
        updateCalendarHeader()
    }
    
    @objc func moveToNext(_ sender: Any) {
        guard let newPage = Calendar.current.date(byAdding: .month, value: 1, to: currentPage) else { return }
        
        // newPage가 오늘의 달보다 이후라면 업데이트하지 않음
        if Calendar.current.compare(newPage, to: Date(), toGranularity: .month) == .orderedDescending { return }
        
        currentPage = newPage
        calendarView.setCurrentPage(currentPage, animated: true)
        updateCalendarHeader()
    }
    
    private func updateCalendarHeader() {
        monthLabel.text = dateFormatter.string(from: currentPage)
    }
    
    // MARK: - layout, ui
    // tableView의 콘텐츠 높이에 따라 contentView의 높이를 동적으로 조정
    func updateContentViewHeight() {
        self.view.layoutIfNeeded() // 레이아웃 강제 업데이트
        
        let titleSize = titleLabel.sizeThatFits(CGSize(width: titleLabel.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let titleHeight = CGFloat(titleSize.height)
        var contentHeight = titleHeight + 854
        
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
    
    @objc func tapCompleteBtn() {
        
    }
    
    func setProcessBar() {
        self.progressBarView.ratio = 0.0
    }
    
    func setUI() {
        view.backgroundColor = UIColor.background.secondary
    }
    
    func setLayout() {
        [topBackgroundView, bottomBackgroundView, contentScrollView].forEach({ view.addSubview($0) })
        [contentView].forEach({ contentScrollView.addSubview($0) })
        [backBtn, titleStack, dayStack, processRateBlock, calendarBackgroundView, calendarView, completeBtn].forEach({ contentView.addSubview($0) })
        
        [categoryMarkImage, titleLabel].forEach({ titleStack.addArrangedSubview($0) })
        [dayLabel, dateLabel].forEach({ dayStack.addArrangedSubview($0) })
        
        [calendarHeaderStack, calendarBar].forEach({ calendarView.addSubview($0) })
        [processRateLabel, processPercent, progressBarView, processMarkImage, processHelperLabel].forEach({ processRateBlock.addSubview($0) })
        
        [calendarPreMoveBtn, monthLabel, calendarNextMoveBtn].forEach {
            calendarHeaderStack.addArrangedSubview($0)}
        
        self.topBackgroundView.snp.makeConstraints {
            $0.right.left.equalTo(self.view.safeAreaLayoutGuide)
            $0.top.equalTo(view.snp.top)
            $0.height.equalTo(450)
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
            $0.height.equalTo(1000)
        }
        
        self.backBtn.snp.makeConstraints {
            $0.top.left.equalToSuperview().inset(20)
            $0.height.width.equalTo(24)
        }
        
        self.titleStack.snp.makeConstraints {
            $0.top.equalTo(backBtn.snp.bottom).offset(52)
            $0.centerX.equalToSuperview()
            $0.width.lessThanOrEqualToSuperview().inset(20)
        }
        
        self.categoryMarkImage.snp.makeConstraints{
            $0.width.height.equalTo(24)
        }
        
        self.dayStack.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        
        self.processRateBlock.snp.makeConstraints {
            $0.top.equalTo(dayStack.snp.bottom).offset(52)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(110)
        }
        
        self.processRateLabel.snp.makeConstraints {
            $0.top.left.equalToSuperview().inset(16)
        }
        
        self.processPercent.snp.makeConstraints {
            $0.top.right.equalToSuperview().inset(16)
        }
        
        self.progressBarView.snp.makeConstraints {
            $0.top.equalTo(processRateLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(8)
        }
        
        self.processMarkImage.snp.makeConstraints {
            $0.left.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(18)
            $0.height.width.equalTo(20)
        }
        
        self.processHelperLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(19)
            $0.left.equalTo(processMarkImage.snp.right).offset(8)
        }
        
        self.calendarView.snp.makeConstraints {
            $0.top.equalTo(processRateBlock.snp.bottom).offset(43)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(430)
        }
        
        self.calendarHeaderStack.snp.makeConstraints {
            $0.top.equalToSuperview().inset(32)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        self.calendarPreMoveBtn.snp.makeConstraints {
            $0.height.equalTo(20)
        }
        
        self.calendarNextMoveBtn.snp.makeConstraints {
            $0.height.equalTo(20)
        }
        
        self.calendarBar.snp.makeConstraints {
            $0.top.equalToSuperview().inset(130)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        self.calendarBackgroundView.snp.makeConstraints {
            $0.top.equalTo(calendarView)
            $0.bottom.left.right.equalToSuperview()
        }
        
        self.completeBtn.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.bottom.left.right.equalToSuperview().inset(20)
        }
    }
    
    @objc func moveToBackPage() {
        navigationController?.popViewController(animated: true)
    }
}

extension RoutineInfoViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    // 오늘 이후의 날짜는 선택이 불가능
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    // 커스텀 셀 로드
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        guard let cell = calendar.dequeueReusableCell(withIdentifier: CalendarCell.description(), for: date, at: position) as? CalendarCell else { return FSCalendarCell() }
        
        let day = Calendar.current.component(.day, from: date)
        let currentMonth = Calendar.current.component(.month, from: calendar.currentPage)
        let dateMonth = Calendar.current.component(.month, from: date)
  
        cell.day = day
        cell.setLayout()
        
        cell.resetOpacity()
        
        // 이번달 cell 이 아닌 경우 opacity 처리
        if currentMonth != dateMonth {
            cell.setOpacity()
        }
        return cell
    }
    
    // 달력을 스크롤(페이지 이동)하면 호출됩니다.
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // 달력이 스크롤되어 현재 페이지(월)가 바뀔 때마다 currentPage와 monthLabel을 갱신
        currentPage = calendar.currentPage
        updateCalendarHeader()
    }
}
