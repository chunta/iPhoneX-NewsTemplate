//
//  MockData.swift
//  Chiv
//
//  Created by user on 2018/7/28.
//  Copyright © 2018年 user. All rights reserved.
//

import Foundation
class MockData {
    fileprivate static let dictionaryData: [String : Array<String>] = [
                                             "即時"  : ["科技","娛樂","運動","論壇","美食","教育","旅遊","汽車","醫藥","美容時尚"],
                                             "日報"  : ["1","2","3"],
                                             "雜誌"  : ["A","B","C"],
                                             "動新聞"  : ["i","ii","iii"]]
    fileprivate static var cats:[String] = []
    class func categories()->Array<String> {
        if (cats.count == 0) {
            for (key,_) in dictionaryData {
                cats.append(key)
            }
        }
        return cats
    }
    class func titles(key:String)->Array<String> {
        return dictionaryData[key]!
    }
    class func subcatres(cat:String) {
        
    }
}

