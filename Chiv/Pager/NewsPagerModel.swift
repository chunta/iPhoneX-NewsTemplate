//
//  NewsPagerModel.swift
//  Chiv
//
//  Created by Cindy on 2018/7/30.
//  Copyright © 2018年 user. All rights reserved.
//

import Foundation
import SwiftHTTP
import JSONModel
import PKHUD

struct NewsPage: Codable {
    let _id:String?
    let title:String?
}
struct NewsPagers: Codable {
    let content:Array<NewsPage>?
}
class NewsPagerModel {
    class func requestList(completionHandler: @escaping (_ list:Array<NewsPage>?) -> Void){
        HUD.show(.progress)
        HTTP.GET("https://dl.dropboxusercontent.com/s/xgf1e64d5kk9a8p/PagerModel.json", parameters: nil) { response in
            DispatchQueue.main.async {
                HUD.hide()
                let jsonDecoder = JSONDecoder()
                let modelObject = try? jsonDecoder.decode(NewsPagers.self, from: response.data)
                completionHandler(modelObject?.content)
            }
        }
    }
}
