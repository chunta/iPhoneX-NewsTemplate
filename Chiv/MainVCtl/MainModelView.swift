//
//  NewsListMView.swift
//  Chiv
//
//  Created by user on 2018/7/29.
//  Copyright © 2018年 user. All rights reserved.
//

import Foundation
import SwiftHTTP
import JSONModel
import PKHUD

struct MainModel: Codable {
    let _id:String
    let title:String
    let imgurl:String
}
struct MainModelList: Codable {
    let content:[MainModel]
}

protocol MainModelViewDelegate {
    func requestImgComplete(indexPath:NSIndexPath)
}

class MainModelView {
    class func requestList(completionHandler: @escaping (_ list:Array<MainModel>?) -> Void){
        HUD.show(.progress)
        HTTP.GET("https://dl.dropboxusercontent.com/s/kmt2uxoychhpg0n/MainModel.json", parameters: nil) { response in
            print(Thread.isMainThread)
            DispatchQueue.main.async {
                HUD.hide()
                let jsonDecoder = JSONDecoder()
                let modelObject = try? jsonDecoder.decode(MainModelList.self, from: response.data)
                completionHandler(modelObject?.content)
            }
        }
    }
    
    fileprivate static var imgmap:Dictionary<String, UIImage> = Dictionary<String, UIImage>()
    class func getImg(url:String)->UIImage? {
        if (imgmap[url] != nil) {
            return imgmap[url]!
        }
        return nil
    }
    
    fileprivate static var urlmap:Set<String> = Set<String>()
    class func requestImg(url:String, indexPath:NSIndexPath, del:MainModelViewDelegate) {
        if (urlmap.contains(url)==false)
        {
            print(url)
            //--------
            urlmap.insert(url)
            HTTP.GET(url, parameters: nil) { response in
                DispatchQueue.main.async {
                    HUD.hide()
                    if (response.error==nil) {
                        print("Complete load image", indexPath.row)
                        let img:UIImage = UIImage.init(data: response.data)!
                        imgmap[url] = img
                        del.requestImgComplete(indexPath: indexPath)
                    }else {
                        urlmap.remove(url)
                    }
                }
            }
            //--------
        }
    }
}

