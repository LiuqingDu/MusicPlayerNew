
import UIKit
/**
*get image
*/
func getImageWithUrl(urlString:NSString)->UIImage?{
    if ( urlString.length<1 ){
       return nil
    }
    var url : NSURL = NSURL(string:urlString as String)!
    var data : NSData = NSData(contentsOfURL:url)!
    var image : UIImage = UIImage(data:data, scale: 1.0)!
    return image
}

/**
*get lyric
*/
func parseLyricWithUrl(urlString:NSString)->NSArray?{
    if ( urlString.length < 2 ){
        return nil
    }
    var url : NSURL = NSURL(string:urlString as String)!
    var lyc : NSString = NSString(contentsOfURL: url, encoding:NSUTF8StringEncoding, error: nil)!
    
    var result:NSMutableArray = NSMutableArray()
    for lStr in lyc.componentsSeparatedByString("\n") {
        var item:NSString = lStr as! NSString
        if(item.length>0){
            var dic:NSDictionary = NSDictionary()
            var startrange:NSRange = item.rangeOfString("[")
            var stoprange:NSRange = item.rangeOfString("]")
            if stoprange.length == 0{
                
                var songLrc:SongLrc = SongLrc()
                songLrc.total=NSNumber(int: -1)// second
                songLrc.time=""// time
                songLrc.text=item// lyric
                result.addObject(songLrc)
            }else{
                var content:NSString = item.substringWithRange(NSMakeRange(startrange.location+1, stoprange.location-startrange.location-1))
                
                if (content.length == 8) {
                    var minute:NSString = content.substringWithRange(NSMakeRange(0, 2))
                    var second:NSString = content.substringWithRange(NSMakeRange(3, 2))
                    var mm:NSString = content.substringWithRange(NSMakeRange(6, 2))
                    var time:NSString = NSString(format: "%@:%@.%@", minute,second,mm)
                    var total:NSNumber = NSNumber(integer: minute.integerValue * 60 + second.integerValue)
                    var lyric:NSString = item.substringFromIndex(10)
                    
                    var songLrc:SongLrc = SongLrc()
                    songLrc.total=total// second
                    songLrc.time=time// time
                    songLrc.text=lyric// lyric
                    result.addObject(songLrc)
               }
            }
            
        }
    }
    return result
}