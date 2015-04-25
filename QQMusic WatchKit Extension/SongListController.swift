//
//  SongListInterfaceController.swift
//  QQMusic
//
//  Created by 方武显 on 15/4/11.
//  Copyright (c) 2015年 小五哥Swift教程. All rights reserved.
//

import Foundation
import WatchKit

class SongListController:WKInterfaceController {
    var dataSource=[Song]()
    //列表控件
    @IBOutlet weak var table: WKInterfaceTable!
    
    //接收传过来的数据
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let data = context as? [Song]{
           self.dataSource=data
        }
    }
    
    //显示列表数据
    override func willActivate() {
        super.willActivate()
        table.setNumberOfRows(dataSource.count, withRowType: "SongRowType")
        for (index, song) in enumerate(dataSource) {
            if let row = table.rowControllerAtIndex(index) as? SongRowController {
                row.titleLabel.setText(song.title as String)
                row.subTitleLabel.setText(song.author as String)
            }
        }
    }
    
    //点击某一行返回
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
         let song = dataSource[rowIndex]
         self.dismissController()
    }
}