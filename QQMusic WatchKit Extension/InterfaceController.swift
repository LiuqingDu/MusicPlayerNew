//
//  InterfaceController.swift
//  QQMusic WatchKit Extension
//
//  Created by 方武显 on 15/4/11.
//  Copyright (c) 2015年 小五哥Swift教程. All rights reserved.
//

import WatchKit
import Foundation
import MediaPlayer

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var iconImage: WKInterfaceImage!
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var lrcLabel:WKInterfaceLabel!
    
    @IBOutlet weak var playButton: WKInterfaceButton!
    var tableData=[Song]();
    var currentLrcData:NSArray? = NSArray()
    var currentSong:Song = Song()
    var currentIndex:NSInteger = 0
    var audioPlayer:MPMoviePlayerController=MPMoviePlayerController()
    var provider:DataProvider=DataProvider()
    var timer:NSTimer?
    var isPlaying:Bool=false

    override func willActivate() {
        super.willActivate()
        if tableData.count==0 {
            //请求列表数据
            provider.getSongList(1) { (results) -> () in
                let errorCode:NSInteger=results["error_code"] as! NSInteger
                let result:NSDictionary=results["result"] as! NSDictionary
                if (errorCode==22000) {
                    let resultData:NSArray = result["songlist"]as! NSArray
                    var list=[Song]()
                    for(var index:Int=0;index<resultData.count;index++){
                        var dic:NSDictionary = resultData[index] as! NSDictionary
                        var song:Song=Song()
                        song.setValuesForKeysWithDictionary(dic as NSDictionary as [NSObject : AnyObject])
                        list.append(song)
                    }
                    self.tableData=list
                    self.settCurrentSong(list[0] as Song)
                }
            }
        }
    }

    func settCurrentSong(song:Song){
      titleLabel.setText("\(song.title)-\(song.author)")
      iconImage.setImage(getImageWithUrl(song.pic_premium))
      self.audioPlayer.stop()
        isPlaying=false
      self.playButton.setBackgroundImage(UIImage(named: "player_btn_play_normal.png"))
      getCurrentMp3(song)
      getCurrentLrc(song.lrclink)
        timer?.invalidate()
        timer=NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "updateTime", userInfo: nil, repeats: true)
    }
    
    //获取当前mp3
    func getCurrentMp3(song:Song){
        provider.getSongMp3(song, reciveBlock: { (results) -> () in
            self.audioPlayer.contentURL=NSURL(string: results as String)
        })
    }
    
    //获取歌词
    func getCurrentLrc(lrclick:NSString){
        currentLrcData=parseLyricWithUrl(lrclick)
    }
    
    //更新播放时间
    func updateTime(){
        //显示歌词
        if currentLrcData != nil {
            let c=audioPlayer.currentPlaybackTime
            if c>0.0{
                let all:Int=Int(c)
                // 查找比当前秒数大的第一条
                var predicate:NSPredicate = NSPredicate(format: "total < %d", all)
                var lrcList:NSArray = currentLrcData!.filteredArrayUsingPredicate(predicate)
                if lrcList.count > 0{
                    var lrcLine:SongLrc = lrcList.lastObject as! SongLrc
                    lrcLabel.setText(lrcLine.text as String)
                }
            }
        }
    }
    
    @IBAction func playSong() {
        if(isPlaying==true){
            //停止播放
            self.audioPlayer.pause()
            self.playButton.setBackgroundImage(UIImage(named: "player_btn_play_normal.png"))
            isPlaying=false
        }else{
            //开始/继续播放
            self.audioPlayer.play()
            self.playButton.setBackgroundImage(UIImage(named: "player_btn_pause_normal.png"))
            isPlaying=true
        }
    }
    
    //上一首
    @IBAction func preSong() {
        if(currentIndex>0){
            currentIndex--
        }
        currentSong=tableData[currentIndex]
        settCurrentSong(currentSong)
    }
  
    //下一首
    @IBAction func nextSong() {
        if(currentIndex < tableData.count){
            currentIndex++
        }
        currentSong=tableData[currentIndex]
        settCurrentSong(currentSong)
    }
    
    //页面使用storyBoard跳转时传参
    override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
        NSLog("segueIdentifier%@", segueIdentifier)
        if segueIdentifier == "songListSegue"{
            return self.tableData
        }else{
            return nil
        }
    }
}
