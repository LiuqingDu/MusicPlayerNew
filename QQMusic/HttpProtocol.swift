import UIKit

protocol HttpProtocol{
    func didRecieveResults(results:NSDictionary)
}

class HttpController:NSObject{
    
    var delegate:HttpProtocol?
    
    func onSearch(url:String){
        //NSLog("请求地址:%@", url)
        var nsUrl:NSURL=NSURL(string:url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
        var request:NSURLRequest=NSURLRequest(URL:nsUrl)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!,data:NSData!,error:NSError!)->Void in
            if (data != nil){
                var jsonResult:NSDictionary=NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
                self.delegate?.didRecieveResults(jsonResult)
            }
        })
    }
}
