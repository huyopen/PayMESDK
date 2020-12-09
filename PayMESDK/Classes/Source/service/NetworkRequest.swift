//
//  NetworkRequest.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import Foundation

public class NetworkRequest {
    private var url: String
    private var path: String
    private var token: String
    private var params: Data?
    private var publicKey: String
    private var privateKey: String
    
    init(url: String, path: String, token: String, params: Data?, publicKey: String, privateKey: String) {
        self.url = url
        self.path = path
        self.token = token
        self.params = params
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
    
    public func setOnRequest(
        onStart: @escaping () -> (),
        onError: @escaping (Dictionary<Int, Any>) -> (),
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onFinally: @escaping () -> (),
        onExpired: @escaping () -> ()
    ) {
        DispatchQueue.main.async {
            onStart()
        }
        
        let url = NSURL(string: self.url + self.path)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.addValue(self.token, forHTTPHeaderField: "Authorization")
        if(self.url == "https://sbx-static.payme.vn/Upload" || self.url == "https://static.payme.vn/Upload") {
            request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        } else {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

        }
        request.httpBody = self.params
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
        if (error != nil) {
            DispatchQueue.main.async {
                if (error?.localizedDescription != nil) {
                    if (error?.localizedDescription == "The Internet connection appears to be offline.") {
                        onError([500 : ["message" : "Kết nối mạng bị sự cố, vui lòng kiểm tra và thử lại. Xin cảm ơn !"]])
                    } else {
                        onError([500 : ["message" : error?.localizedDescription]])
                    }
                    onFinally()
                } else {
                    onError([500 : ["message" : "Something went wrong" ]])

                }
                
            }
            return
        }
            let json = try? (JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>)
            print(json)
            let code = json!["code"] as! Int
            if code == 1000 {
                if let data = json!["data"] as? Dictionary<String, AnyObject> {
                    DispatchQueue.main.async {
                        onSuccess(data)
                    }
                }
            }
            else {
                if let data = json!["data"] as? Dictionary<String, AnyObject> {
                    print(159,data)
                    DispatchQueue.main.async {
                        onError([code: data])
                        onFinally()
                    }
                }
            }
        }
        task.resume()
    }
    
    public func setOnRequestCrypto(
        onStart: @escaping () -> (),
        onError: @escaping (Dictionary<Int, Any>) -> (),
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onFinally: @escaping () -> (),
        onExpired: @escaping () -> ()
    ) {
        let encryptKey = "10000000"
        let xAPIKey = try? CryptoRSA.encryptRSA(plainText: encryptKey, publicKey: self.publicKey)
        let xAPIAction = CryptoAES.encryptAES(text: path, password: encryptKey)
        var xAPIMessage = ""
        if self.params != nil{
            xAPIMessage = CryptoAES.encryptAES(text: String(data: params!, encoding: .utf8)!, password: encryptKey)
        } else {
            let dictionaryNil = [String:String]()
            let paramsNil = try? JSONSerialization.data(withJSONObject: dictionaryNil)
            xAPIMessage = CryptoAES.encryptAES(text: String(data: paramsNil!, encoding: .utf8)!, password: encryptKey)
        }
        var valueParams = ""
        valueParams += xAPIAction
        valueParams += "POST"
        valueParams += token
        valueParams += xAPIMessage
        valueParams += encryptKey
        let xAPIValidate = CryptoAES.MD5(valueParams)!
        DispatchQueue.main.async {
            onStart()
        }
        
        let url = NSURL(string: self.url)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.addValue(self.token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("app", forHTTPHeaderField: "x-api-client")
        request.addValue(xAPIKey!, forHTTPHeaderField: "x-api-key")
        request.addValue(xAPIAction, forHTTPHeaderField: "x-api-action")
        request.addValue(xAPIValidate, forHTTPHeaderField: "x-api-validate")
        let jsonBody = ["x-api-message": xAPIMessage]
        let dataBody = try? JSONSerialization.data(withJSONObject: jsonBody)
        request.httpBody = dataBody!
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error != nil) {
                DispatchQueue.main.async {
                    if (error?.localizedDescription != nil) {
                        if (error?.localizedDescription == "The Internet connection appears to be offline.") {
                            onError([500 : ["message" : "Kết nối mạng bị sự cố, vui lòng kiểm tra và thử lại. Xin cảm ơn !"]])
                        } else {
                            onError([500 : ["message" : error?.localizedDescription]])
                        }
                        onFinally()
                    } else {
                        onError([500 : ["message" : "Something went wrong" ]])

                    }
                    
                }
                return
            }
            
            let json = try? (JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>)
            guard let xAPIMessageResponse = json?["x-api-message"] as? String else {
                return
            }
            
            guard let headers = response as? HTTPURLResponse else {
                return
            }
            let xAPIKeyResponse = headers.allHeaderFields["x-api-key"] as! String
            let xAPIValidateResponse = headers.allHeaderFields["x-api-validate"] as! String
            let xAPIActionResponse = headers.allHeaderFields["x-api-action"] as! String
            
            let decryptKey = try? CryptoRSA.decryptRSA(encryptedString: xAPIKeyResponse, privateKey: self.privateKey)
            
            var validateString = ""
            validateString += xAPIActionResponse
            validateString += "POST"
            validateString += self.token
            validateString += xAPIMessageResponse
            validateString += decryptKey!
         
            let validateMD5 = CryptoAES.MD5(validateString)!
            
            let stringJSON = CryptoAES.decryptAES(text: xAPIMessageResponse, password: decryptKey!)
            let dataJSON = stringJSON.data(using: .utf8)
            guard let finalJSON = try? JSONSerialization.jsonObject(with: dataJSON!, options: []) as? Dictionary<String, AnyObject> else {
                return
            }
            
            let code = finalJSON!["code"] as! Int
            if code == 1000 {
                if let data = finalJSON!["data"] as? Dictionary<String, AnyObject> {
                    DispatchQueue.main.async {
                        onSuccess(data)
                    }
                }
            }
            else {
                if let data = finalJSON!["data"] as? Dictionary<String, AnyObject> {
                    print(159,data)
                    DispatchQueue.main.async {
                        onError([code: data])
                        onFinally()
                    }
                }
            }
        }
        task.resume()
    }
}

