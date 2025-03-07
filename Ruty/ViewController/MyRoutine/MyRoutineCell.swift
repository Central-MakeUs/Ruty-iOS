//
//  MyRoutineCell.swift
//  Ruty
//
//  Created by 정성희 on 3/4/25.
//

import UIKit
import Alamofire

class MyRoutineCell: UITableViewCell {

    var preViewController : UIViewController?
    
    static let identifier = "MyRoutineCell"
    
    private var id: Int?
    
    private var category: String?
    
    private var historyData: JSONModel.RoutineHistoryResponses?
    private var progressData: JSONModel.RoutineProgressResponses?

    private let cellBlock = UIView().then {
        $0.backgroundColor = UIColor.background.tertiary
        $0.layer.cornerRadius = 20
    }
    
    private let routineStatusBlock = UIView().then {
        $0.backgroundColor = UIColor.fill.brandTertiary
        $0.layer.cornerRadius = 18
    }
    
    private let routineStatusLabel = UILabel().then {
        $0.text = "-"
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 12)
        $0.textColor = UIColor.font.brandStrong
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    private let routineLabel = UILabel().then {
        $0.text = "-"
        $0.font = UIFont(name: Font.semiBold.rawValue, size: 20)
        $0.textColor = UIColor(23, 23, 25, 1)
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    private let dayStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .leading
        $0.distribution = .equalCentering
    }
    
    private let dayLabel = UILabel().then {
        $0.text = "월 - 일"
        $0.font = UIFont(name: Font.medium.rawValue, size: 14)
        $0.textColor = UIColor.font.tertiary
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    private let dateLabel = UILabel().then {
        $0.text = "yyyy.MM.dd - yyyy.MM.dd"
        $0.font = UIFont(name: Font.medium.rawValue, size: 14)
        $0.textColor = UIColor.font.tertiary
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    private let dateBar = UIView().then {
        $0.backgroundColor = UIColor.border.secondary
    }
    
    private let markImage = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "housing")
    }
    
    private let showRoutineInfoBtn = UIButton().then {
        $0.setTitle("루틴 정보보기", for: .normal)
        $0.layer.cornerRadius = 12
        $0.backgroundColor = UIColor.fill.brand
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont(name: Font.semiBold.rawValue, size: 16)
        $0.addTarget(self, action: #selector(tapShowRoutineInfoBtn), for: .touchUpInside)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
 
    func setupLayout() {
        [cellBlock].forEach({ contentView.addSubview($0) })
        [routineStatusBlock, markImage, routineLabel, dayStack, showRoutineInfoBtn].forEach({ cellBlock.addSubview($0) })
        [routineStatusLabel].forEach({ routineStatusBlock.addSubview($0) })
        [dayLabel, dateBar, dateLabel].forEach({ dayStack.addArrangedSubview($0) })
        
        cellBlock.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview().inset(20)
            $0.top.equalToSuperview()
            //$0.height.equalTo(200)
        }
        
        routineStatusBlock.snp.makeConstraints {
            $0.top.left.equalToSuperview().inset(20)
            $0.height.equalTo(30)
            $0.width.equalTo(45)
        }
        
        routineStatusLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        markImage.snp.makeConstraints {
            $0.left.equalToSuperview().inset(20)
            $0.top.equalTo(routineStatusBlock.snp.bottom).offset(14)
            $0.height.width.equalTo(24)
        }
        
        routineLabel.snp.makeConstraints {
            $0.left.equalTo(markImage.snp.right).offset(8)
            $0.top.equalTo(routineStatusBlock.snp.bottom).offset(12)
            $0.right.equalToSuperview().inset(20)
        }
        
        dayStack.snp.makeConstraints {
            $0.left.equalToSuperview().inset(20)
            $0.top.equalTo(routineLabel.snp.bottom).offset(8)
        }
        
        dateBar.snp.makeConstraints {
            $0.height.equalTo(12)
            $0.width.equalTo(1)
        }
        
        showRoutineInfoBtn.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
    }
    
    func setContent(id: Int, category: String, routineName: String, markImage: String, routineStatusText: String, dayText: String, dateText: String) {
        self.id = id
        self.category = category
        self.routineLabel.text = routineName
        self.markImage.image = UIImage(named: markImage)
        self.routineStatusLabel.text = routineStatusText
        self.dayLabel.text = dayText
        self.dateLabel.text = dateText
    }

    @objc func tapShowRoutineInfoBtn() {
        let nextVC = RoutineInfoViewController()
        nextVC.modalPresentationStyle = .fullScreen
        preViewController?.navigationController?.pushViewController(nextVC, animated: true)
        var isRoutineHistory = false
        var isRoutineProcess = false
        
        var isExecutedHistory = false
        var isExecutedProcess = false
        
        requestLoadRoutineHistory { isBool in
            isRoutineHistory = isBool
            isExecutedHistory = true
            if isExecutedHistory && isExecutedProcess {
                self.moveToRoutineInfoView(isRoutineHistory: isRoutineHistory, isRoutineProcess: isRoutineProcess)
            }
            
        }
        requestRoutineProcess { isBool in
            isRoutineProcess = isBool
            isExecutedProcess = true
            if isExecutedHistory && isExecutedProcess {
                self.moveToRoutineInfoView(isRoutineHistory: isRoutineHistory, isRoutineProcess: isRoutineProcess)
            }
        }
    }

    func moveToRoutineInfoView(isRoutineHistory: Bool, isRoutineProcess: Bool) {
        
        if isRoutineHistory && isRoutineProcess {
            let nextVC = RoutineInfoViewController()
            nextVC.preViewController = preViewController
            nextVC.routineStatus = routineStatusLabel.text
            nextVC.routineID = id
            nextVC.routineName = routineLabel.text
            nextVC.dayString = dayLabel.text
            nextVC.dateString = dateLabel.text
            nextVC.category = category
            nextVC.historyData = historyData
            nextVC.progressData = progressData
            nextVC.modalPresentationStyle = .fullScreen
            self.preViewController?.navigationController?.pushViewController(nextVC, animated: true)
        }
        else {
            ErrorViewController.showErrorPage(viewController: self.preViewController!)
        }
    }
    
    func requestLoadRoutineHistory(onColpleted: @escaping (Bool) -> ()) {
        guard let id = id else { return }
        print("id: \(id)")
        let url = NetworkManager.shared.getRequestURL(api: "/api/routine/history/\(id)")
//        let param = JSONModel.RoutineHistory(routineId: id, year: 2025, month: 3) // 달력 임시 값
//        
//        guard let jsonData = try? JSONEncoder().encode(param),
//              let param = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else { return }
//
        
        let today = Date()
        let calendar = Calendar.current

        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)

        let parameters: [String: Any] = [
            "year": year,
            "month": month
        ]
        
        NetworkManager.shared.requestAPI(url: url, method: .get, encoding: URLEncoding.default, param: parameters) { result in
            
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.RoutineHistoryResponses.self, from: data)
                    if decodedResponse.message == "ok" {
                        print("decodedResponse: \(decodedResponse)")
                        self.historyData = decodedResponse
                        onColpleted(true)
                    }
                    else {
                        print("서버 연결 오류")
                        onColpleted(false)
                    }
                } catch {
                    print("JSON 디코딩 오류: \(error)")
                    onColpleted(false)
                }
            case .failure(let error):
                // 요청이 실패한 경우
                print("API 요청 실패: \(error.localizedDescription)")
                onColpleted(false)
            }
        }
    }
    
    func requestRoutineProcess(onColpleted: @escaping (Bool) -> ()) {
        guard let id = id else { return }
        print("id: \(id)")
        let url = NetworkManager.shared.getRequestURL(api: "/api/routine/history/\(id)/count")
        NetworkManager.shared.requestAPI(url: url, method: .get, encoding: URLEncoding.default, param: nil) { result in
            
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(JSONModel.RoutineProgressResponses.self, from: data)
                    if decodedResponse.message == "ok" {
                        self.progressData = decodedResponse
                        onColpleted(true)
                    }
                    else {
                        print("서버 연결 오류")
                        onColpleted(false)
                    }
                } catch {
                    print("JSON 디코딩 오류: \(error)")
                    onColpleted(false)
                }
            case .failure(let error):
                // 요청이 실패한 경우
                print("process API 요청 실패: \(error.localizedDescription)")
                onColpleted(false)
            }
        }
    }
}
