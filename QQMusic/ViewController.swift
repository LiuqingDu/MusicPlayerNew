//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Liuqing Du on 13/04/2015.
//  Copyright (c) 2015 JuneDesign. All rights reserved.
//

import UIKit
import MediaPlayer
import QuartzCore

class ViewController: UIViewController {
    
    @IBOutlet weak var photoBorderView: UIView!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var playButton:UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel:UILabel!
    @IBOutlet weak var playTimeLabel:UILabel!
    @IBOutlet weak var allTimeLabel:UILabel!   
    @IBOutlet weak var lrcLabel:UILabel!
    
    var tableData:NSArray = NSArray()
    var currentLrcData:NSArray? = NSArray()
    var currentSong:Song = Song()
    var provider:DataProvider=DataProvider()
    var audioPlayer:MPMoviePlayerController=MPMoviePlayerController();
    var timer:NSTimer?
    var currentIndex:NSInteger = 0// current song
    var currentChannel:NSInteger = 0
    var channelList: [NSInteger] = [21, 12, 11]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // change image
        photo.layer.cornerRadius=self.photo.frame.size.width/2.0
        photo.clipsToBounds=true
        photoBorderView.layer.cornerRadius=self.photoBorderView.frame.size.width/2.0
        photoBorderView.clipsToBounds=true
        // blur
        let blurEffect=UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blureView=UIVisualEffectView(effect: blurEffect)
        blureView.frame=self.view.frame
        backgroundImageView.addSubview(blureView)
        // slider
        progressSlider.setMinimumTrackImage(UIImage(named: "player_slider_playback_left.png"), forState: UIControlState.Normal)
        progressSlider.setMaximumTrackImage(UIImage(named: "player_slider_playback_right.png"), forState: UIControlState.Normal)
        progressSlider.setThumbImage(UIImage(named: "player_slider_playback_thumb.png"), forState: UIControlState.Normal)
        // notification
        NSNotificationCenter.defaultCenter().addObserverForName(MPMoviePlayerPlaybackDidFinishNotification, object: audioPlayer, queue: nil) { (notification) -> Void in
            // next song
           // self.nextSongClick(nil)
        }
        // get list
        getList(channelList[currentChannel])
    }
    
    func getList(listNumber: NSInteger) {
        // get list
        provider.getSongList(listNumber) { (results) -> () in
            let errorCode:NSInteger=results["error_code"] as! NSInteger
            //let result:NSDictionary=results["result"]as! NSDictionary
            if (errorCode==22000) {
                let resultData:NSArray = results["song_list"] as! NSArray
                let list:NSMutableArray = NSMutableArray()
                
                for(var index:Int=0;index<resultData.count;index++){
                    var dic:NSDictionary = resultData[index]as! NSDictionary
                    var song:Song=Song()
                    song.setValuesForKeysWithDictionary(dic as NSDictionary as [NSObject : AnyObject])
                    list.addObject(song)
                }
                self.tableData=list
                self.settCurrentSong(list[0] as! Song)
            }
        }
    }

    //
    var requestList: Bool = false
    var sourceListView: PlayListView? = nil
    func getNextList(sender: PlayListView) {
        if currentChannel + 1 < channelList.count {
            currentChannel += 1
        } else {
            currentChannel = 0
        }
        requestList = true
        sourceListView = sender
        getList(channelList[currentChannel])
    }
    
    // animation
    func rotationAnimation(){
        let rotation=CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.timingFunction=CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        rotation.toValue=2*M_PI
        rotation.duration=16
        rotation.repeatCount=HUGE
        rotation.autoreverses=false
        photo.layer.addAnimation(rotation, forKey: "rotationAnimation")
        pauseLayer(photo.layer)
    }
    
    // stop animation
    func pauseLayer(layer:CALayer){
        var pausedTime:CFTimeInterval=layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        layer.speed=0.0
        layer.timeOffset=pausedTime
    }
    
    // start animation
    func resumeLayer(layer:CALayer){
        var pausedTime:CFTimeInterval = layer.timeOffset
        layer.speed=1.0
        layer.timeOffset=0.0
        layer.beginTime=0.0
        var timeSincePause:CFTimeInterval=layer.convertTime(CACurrentMediaTime(), fromLayer: nil)-pausedTime
        layer.beginTime=timeSincePause
    }
    
    @IBAction func shareButton(sender: UIButton) {
        let actionSheet = UIActionSheet(title: "Share with friends", delegate: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Share with Facebook", "Share with Twitter")
        
        actionSheet.showInView(self.view)
        
    }
    
    // display list
    //var listShowed: Bool = false
    @IBAction func showPlayList(sender: UIButton) {
        //if !listShowed {
            var playList=NSBundle.mainBundle().loadNibNamed("PlayListView", owner: self, options: nil).last as? PlayListView
            playList!.tableData=self.tableData
            playList!.viewContorller=self
            playList!.showPlayListView()
            //listShowed = true
        //}
    }
    
    // set current song
    func settCurrentSong(curSong:Song){
        currentSong=curSong
        currentIndex=tableData.indexOfObject(curSong)
        photo.image=getImageWithUrl(currentSong.pic_big)
        backgroundImageView.image=photo.image
        titleLabel.text=currentSong.title as String
        artistLabel.text="— \(currentSong.author) —"
        playButton.selected=false
        playTimeLabel.text="00:00"
        lrcLabel.text=""
        self.progressSlider.value=0.0
        self.rotationAnimation()
        self.audioPlayer.stop()
        timer?.invalidate()
        timer=NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "updateTime", userInfo: nil, repeats: true)
        
        getCurrentMp3(curSong)
        getCurrentLrc(curSong.lrclink)
        
        likeSong = false
    }
    
    // get song
    func getCurrentMp3(song:Song){
        provider.getSongMp3(song, reciveBlock: { (results) -> () in
            self.audioPlayer.contentURL=NSURL(string: results as String)
            self.audioPlayer.play()
            self.resumeLayer(self.photo.layer)
            self.playButton.selected=true
        })
    }
    
    // get lyric
    func getCurrentLrc(lrclick:NSString){
       currentLrcData=parseLyricWithUrl(lrclick)
    }
    
    // play
    @IBAction func playButtonClick(sender: UIButton) {
        if sender.selected {
            // pause
            self.audioPlayer.pause()
            pauseLayer(photo.layer)
        }else{
            // play
            self.audioPlayer.play()
            resumeLayer(photo.layer)
        }
        sender.selected = !sender.selected
    }
    
    // pre
    @IBAction func preSongClick(sender: UIButton){
        if(currentIndex>0){
            currentIndex--
        }
        currentSong=tableData.objectAtIndex(currentIndex) as! Song
        settCurrentSong(currentSong)
    }
    
    // next
    @IBAction func nextSongClick(sender: UIButton?){
        if(currentIndex < tableData.count){
            currentIndex++
        }
        currentSong=tableData.objectAtIndex(currentIndex) as! Song
        settCurrentSong(currentSong)
    }
    
    // random play
    var random:Bool = false
    @IBAction func randomClick(sender: UIButton) {
        if !random {
            sender.setImage(UIImage(named: "player_btn_repeat_normal@2x.png"), forState: UIControlState.Normal)
        } else {
            sender.setImage(UIImage(named: "player_btn_random_normal@2x.png"), forState: UIControlState.Normal)
        }
        random = !random
    }
    
    // like song
    var likeSong: Bool = false
    @IBAction func likeClick(sender: UIButton) {
        if !likeSong {
            sender.setImage(UIImage(named: "player_btn_favorited_normal@2x.png"), forState: UIControlState.Normal)
        } else {
            sender.setImage(UIImage(named: "player_btn_favorite_normal@2x.png"), forState: UIControlState.Normal)
        }
        likeSong = !likeSong
    }
    
    // time
    func updateTime(){
        let c=audioPlayer.currentPlaybackTime
        let t=audioPlayer.duration
        // ending
        let endall:Int=Int(t)
        let endm:Int=endall % 60// second
        let endf:Int=Int(endall/60)// minute
        var endTime=NSString(format:"%02d:%02d",endf,endm)
        self.allTimeLabel.text=endTime as String;
        
        if c>0.0 {
            let p:CFloat=CFloat(c/t)
            progressSlider.value=p;
            let all:Int=Int(c)// total second
            let m:Int=all % 60// second
            let f:Int=Int(all/60)// mimute
            var time=NSString(format:"%02d:%02d",f,m)
            playTimeLabel.text=time as String
            
            // lyric
            if currentLrcData != nil {
                // find next lyric
                var predicate:NSPredicate = NSPredicate(format: "total < %d", all)
                var lrcList:NSArray = currentLrcData!.filteredArrayUsingPredicate(predicate)
                if lrcList.count > 0{
                    var lrcLine:SongLrc = lrcList.lastObject as!SongLrc
                    lrcLabel.text = lrcLine.text as String
                }
            }
        }
    }
}



