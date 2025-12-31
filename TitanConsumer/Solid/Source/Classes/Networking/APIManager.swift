//
//  APIManager.swift
//  Solid
//
//  Created by Solid iOS Team on 2/8/21.
//

import Foundation
import Alamofire
import UIKit
import TrustKit

class CustomSessionDelegate: SessionDelegate {
    override func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
         // Call into TrustKit here to do pinning validation
         if TrustKit.sharedInstance().pinningValidator.handle(challenge, completionHandler: completionHandler) == false {
             // TrustKit did not handle this challenge: perhaps it was not for server trust
             // or the domain was not pinned. Fall back to the default behavior
             debugPrint("in trust kit url session")
             completionHandler(.performDefaultHandling, nil)
         }
     }
}

class APIManager: SessionDelegate {
    // MARK: - Vars & Lets
    private let sessionManager: Session
    static var networkEnviroment: NetworkEnvironment = .productionLive
    public static var customHeader: [String: String] = [:]
    
    // MARK: - Vars & Lets
    private static var sharedApiManager: APIManager = {
        let apiManager = APIManager(sessionManager: Session(delegate: CustomSessionDelegate(), eventMonitors: []))
        return apiManager
    }()
    
    // MARK: - Accessors
    class func shared() -> APIManager {
        return sharedApiManager
    }
    
    // MARK: - Initialization
    private init(sessionManager: Session) {
        self.sessionManager = Session(delegate: CustomSessionDelegate(), eventMonitors: [])
    }
    
    func call<T>(type: EndPointType, params: Parameters? = nil, handler: @escaping (T?, _ error: AlertMessage?) -> Void) where T: Codable {
        self.sessionManager.request(type.url,
                                    method: type.httpMethod,
                                    parameters: params,
                                    encoding: type.encoding,
                                    headers: type.headers).validate().responseJSON { data in
            
            if let respData = data.data {
                let response = String(data: respData, encoding: .utf8)
                #if DEBUG
                debugPrint("Response : \(response ?? "No response data")")
                #endif
            }
            
            switch data.result {
            case .success(_):
                let decoder = JSONDecoder()
                if let jsonData = data.data {
                    do {
                        let result = try decoder.decode(T.self, from: jsonData)
                        handler(result, nil)
                        
                    } catch let error {
                        print(error)
                        handler(nil, nil)
                    }
                }
            case .failure(_):
                if data.response?.statusCode == 503 { // show maintenance page..
                    AppGlobalData.shared().showMaintenanceScreen()
                } else if data.response?.statusCode == 401 { // No need to show alert when token API error occurs
                    let baseVC = BaseVC()
                    baseVC.clearDataOnLogout()
                    baseVC.gotoWelcomeScreen()
                } else {
                    handler(nil, self.parseApiError(data: data.data))
                }
            }
        }.cURLDescription { description in
            #if DEBUG
            debugPrint(description)
            #endif
        }
    }
    
    private func parseApiError(data: Data?) -> AlertMessage {
        let decoder = JSONDecoder()
        if let jsonData = data, let error = try? decoder.decode(ErrorObject.self, from: jsonData) {
            let errorAlert = AlertMessage()
            errorAlert.title = error.key ?? "Error"
            errorAlert.body = error.message
            errorAlert.errorCode = error.code ?? "0"
            errorAlert.statusCode = "\(error.statusCode ?? 0)"
            return errorAlert
        }
        return AlertMessage()
    }
    
    // Download
    func downloadFile(type: EndPointType, filename: String, completion:@escaping ((_ filePath: URL?, _ error: Error?) -> Void)) {
        let fileName = filename
        let destination: DownloadRequest.Destination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            // Remove existing files, to avoid multiple txn pdf files.
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL,
                                                                           includingPropertiesForKeys: nil,
                                                                           options: .skipsHiddenFiles)
                for fileURL in fileURLs where fileURL.pathExtension == "pdf" {
                    try FileManager.default.removeItem(at: fileURL)
                }
            } catch {
                #if DEBUG
                debugPrint(error)
                #endif
            }
            
            documentsURL.appendPathComponent(fileName)
            return (documentsURL, [.removePreviousFile])
        }
        
        AF.download(type.url, headers: type.headers, to: destination).response { response in
            completion(response.fileURL, response.error)
        }
    }
    
    func downloadConfigJsonFile(urlPath: String, completion: @escaping (Data?, String?) -> Void) {
        guard let urlTarget = URL(string: urlPath) else {
            completion(nil, nil)
            return
        }
        
        AF.request(urlTarget, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { response in
            switch response.result {
            case .success:
                if let json = response.data {
                    completion(json, nil)
                } else {
                    completion(nil, "Json Invalid")
                }
            case .failure(let error):
                print(error)
                completion(nil, error.localizedDescription)
            }
        })
    }
    
    func uploadFile<T>(type: EndPointType, filename: String, frontImage: UIImage, bfilename: String, backImage: UIImage, completion:@escaping (T?, _ error: AlertMessage?) -> Void) where T: Codable {
        let param = ["accountId": AppGlobalData.shared().accountData?.id] // Optional for extra parameter
        let imageData = frontImage.jpegData(compressionQuality: 1)
        let backimageData = backImage.jpegData(compressionQuality: 1)
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData!, withName: filename, fileName: "front.png", mimeType: "image/png")
                multipartFormData.append(backimageData!, withName: bfilename, fileName: "back.png", mimeType: "image/png")
                
                for (key, value) in param {
                    multipartFormData.append("\(String(describing: value))".data(using: String.Encoding.utf8)!, withName: key)
                    
                }
            },
            to: type.url, method: .patch, headers: type.headers)
        .responseJSON { data in
            if let respData = data.data {
                let response = String(data: respData, encoding: .utf8)
                #if DEBUG
                debugPrint("Response : \(response ?? "No response data")")
                debugPrint(data.result)
                #endif
                switch data.result {
                    
                case .success(_):
                    let decoder = JSONDecoder()
                    if let jsonData = data.data {
                        do {
                            let result = try decoder.decode(T.self, from: jsonData)
                            completion(result, nil)
                            
                        } catch {
                            // No catch case handled yet.
                        }
                    }
                case .failure(_):
                    completion(nil, self.parseApiError(data: data.data))
                }
            }
        }.cURLDescription { description in
            #if DEBUG
            debugPrint(description)
            #endif
        }
    }
}

struct DelegatePostData: Codable {
	public var content: [String: String]?
	public init( content: [String: String]?) {
		self.content = content
	}
}
