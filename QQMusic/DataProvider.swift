//
//  DataProvider.swift
//  MusicPlayer
//
//  Created by Liuqing Du on 13/04/2015.
//  Copyright (c) 2015 JuneDesign. All rights reserved.
//

import Foundation

class DataProvider:NSObject,HttpProtocol{
    
    var blockRecive:(NSDictionary) -> () = {param in }
    var eHttp:HttpController = HttpController()
    override init(){
        super.init()
        eHttp.delegate=self
    }
    
    //**
    //* get list
    //*
    func getSongList(list:NSInteger, reciveBlock:(NSDictionary) -> () = {param in }){
        blockRecive=reciveBlock
        eHttp.onSearch("http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.billboard.billList&type=\(list)&page_no=1&page_size=50&scene_id=42&item_id=115&version=5.2.1&from=ios&channel=appstore")
        //
        
    }

    //**
    //* get info
    //*
    func getSongMp3(p:Song,reciveBlock:(NSString) -> () = {param in }){
        
        var url:NSString = "http://box.zhangmen.baidu.com/x?op=12&count=1&title=\(p.title)$$\(p.author)$$$$"
        var nsUrl:NSURL=NSURL(string:url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
        var request:NSURLRequest=NSURLRequest(URL:nsUrl)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!,data:NSData!,error:NSError!)->Void in
            if (data != nil){
                var reciveString:NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
                //
                var strArr:NSArray = reciveString.componentsSeparatedByString("<![CDATA[") as NSArray
                if strArr.count > 2{
                    var s1:NSString = strArr[1].description
                    s1 = s1.stringByReplacingOccurrencesOfString("]]></encode><decode>", withString: "")
                    var sArr:NSArray = s1.componentsSeparatedByString("/") as NSArray
                    var lastS:NSString = sArr.lastObject as! NSString
                    
                    var s2Arr:NSArray = strArr[2].description.componentsSeparatedByString("]]") as NSArray
                    
                    s1 = s1.stringByReplacingOccurrencesOfString(lastS as String, withString:s2Arr[0] as! String)
                    
                    reciveBlock(s1)
                }
            }
        })
    }
    //**
    //* get results
    //*
    func didRecieveResults(results:NSDictionary){
        blockRecive(results)
    }
}