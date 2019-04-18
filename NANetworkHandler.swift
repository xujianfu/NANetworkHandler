//
//  NANetworkHandler.swift
//

import UIKit
import Alamofire

public typealias Success = (_ dict : [String:Any])->()
public typealias Failure = (_ error : Error)->()
class NANetworkHandler : NSObject {
    
    static var shareInstance : NANetworkHandler {
        struct Share {
            static let instance = NANetworkHandler()
        }
        return Share.instance
    }
    
    //GET请求
    func getRequest(
        _ urlString: String,
        params: Parameters? = nil,
        success: @escaping Success,
        failure: @escaping Failure)
    {
        request(urlString, params: params, method: .get, success, failure)
    }

    //POST请求
    func postRequest(
        _ urlString: String,
        params: Parameters? = nil,
        success: @escaping Success,
        failure: @escaping Failure)
    {
        request(urlString, params: params, method: .post, success, failure)
    }
    
    //图片上传
    func upLoadImageRequest(urlString : String, params:[String:String], imgArr:[UIImage], name: [String],success : @escaping Success, failure : @escaping Failure){
        
        let headers = ["content-type":"multipart/form-data"]
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                if imgArr.count == 0 {
                    return
                }
                //此处循环上传多占图片
                for (index, value) in imgArr.enumerated() {
                    let imageData = UIImage.jpegData(value)(compressionQuality: 0.5)!
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyyMMddHHmmss"
                    let str = formatter.string(from: Date())
                    let fileName = str+"\(index)"+".jpg"

                    multipartFormData.append(imageData, withName: "imageUpload", fileName: fileName, mimeType: "image/png")
                }
        },
            to: urlString,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let value = response.result.value as? [String: Any] {
                            success(value as [String : Any])
                        }
                    }
                    break
                case .failure(let err):
                    failure(err)
                    break
                }
        }
        )
    }
    
    private func request(_ urlString: String,
                         params:Parameters? = nil,
                         method:HTTPMethod,
                         _ success:@escaping Success,
                         _ failure:@escaping Failure){
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 15
        manager.request(urlString, method: method, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
            case .success:
                if let value = response.result.value as? [String: Any] {
                    success(value as [String : Any])
                }
                break
            case .failure(let err):
                failure(err)
                break
            }
        }
    }
}
