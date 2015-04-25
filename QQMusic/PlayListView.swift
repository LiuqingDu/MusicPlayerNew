//
//  SongListViewController.swift
//  MusicPlayer
//
//  Created by Liuqing Du on 13/04/2015.
//  Copyright (c) 2015 JuneDesign. All rights reserved.
//

import UIKit
class PlayListView: UIView,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var viewBackground: UIView!
    
    @IBOutlet weak var viewContent: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var tableData:NSArray=NSArray()// list data
    var viewContorller:ViewController=ViewController()// controller
    var blureView:UIVisualEffectView!
    // display list
    func showPlayListView(){
        // blur
        let blurEffect=UIBlurEffect(style: UIBlurEffectStyle.Light)
        self.blureView=UIVisualEffectView(effect: blurEffect)
        UIApplication.sharedApplication().keyWindow?.addSubview(blureView)
        
        UIApplication.sharedApplication().keyWindow?.addSubview(self)
        // animate
        var vbFrame:CGRect = self.viewBackground.frame
        vbFrame.origin.y=vbFrame.origin.y+vbFrame.size.height
        self.viewBackground.frame=vbFrame
        blureView.frame=vbFrame;
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            var vbFrame:CGRect = self.viewBackground.frame
            vbFrame.origin.y=vbFrame.origin.y-vbFrame.size.height
            self.viewBackground.frame=vbFrame
            self.blureView.frame=vbFrame;
            self.titleLabel.text="Playlist (Total \(self.tableData.count) Songs)"
        });
    }
    
    func refresh() {
        self.tableView.reloadData()
    }
    
    // get next channel
    @IBAction func nextChannel(sender: UIButton) {
        viewContorller.getNextList(self)
    }
    
    // close
    @IBAction func closePlayListView(sender: AnyObject) {
        //viewContorller.listShowed = false
        self.blureView.removeFromSuperview()
        self.removeFromSuperview()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return tableData.count;
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        // cell
        let cell=UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "douban")
        cell.backgroundColor=UIColor.clearColor()
        // row
        let rowSong:Song=self.tableData[indexPath.row] as! Song
        // text
        cell.textLabel?.text=rowSong.title as String
        // change colour
        if indexPath.row == self.viewContorller.currentIndex{
            cell.textLabel?.textColor=UIColor.greenColor()
        }else{
            cell.textLabel?.textColor=UIColor.whiteColor()
        }
        cell.detailTextLabel?.text=rowSong.author as String
        return cell;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         let rowSong:Song=self.tableData[indexPath.row] as! Song
        viewContorller.settCurrentSong(rowSong)
         self.blureView.removeFromSuperview()
        self.removeFromSuperview()
    }
}
