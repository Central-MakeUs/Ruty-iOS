//
//  DataManager.swift
//  Ruty
//
//  Created by 정성희 on 1/24/25.
//

import Foundation
class DataManager {
    static let shared = DataManager()
    
    private init() { }
    
    var userNickName : String?
    var socialType: String?
}
