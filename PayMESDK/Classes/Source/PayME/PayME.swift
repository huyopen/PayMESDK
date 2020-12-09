//
//  PayME.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

public class PayME{
    internal static var appPrivateKey: String = ""
    internal static var appID: String = ""
    internal static var publicKey: String = ""
    internal static var connectToken : String = ""
    internal static var env : String = ""
    internal static var configColor : [String] = [""]
    internal static var description : String = ""
    internal static var amount : Int = 0
    internal static let packageName = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    internal static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    internal static let deviceID = UIDevice.current.identifierForVendor!.uuidString
    internal static var currentVC : UIViewController?
    
    public enum Action: String {
        case OPEN = "OPEN"
        case DEPOSIT = "DEPOSIT"
        case WITHDRAW = "WITHDRAW"
    }
    
    public func showModal(currentVC : UIViewController){
        PayME.currentVC = currentVC
        currentVC.presentPanModal(Methods())
    }
    
    public static func showKYCCamera(currentVC: UIViewController) {
        PayME.currentVC = currentVC
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        currentVC.navigationController?.pushViewController(KYCCameraController(), animated: true)
    }
    
    public static func openQRCode(currentVC : UIViewController) {
        PayME.currentVC = currentVC
        let qrScan = QRScannerController()
        qrScan.setScanSuccess(onScanSuccess: { response in
            PayME.currentVC!.showSpinner(onView: PayME.currentVC!.view)
            qrScan.dismiss(animated: true)
            PayME.payWithQRCode(QRContent: response, onSuccess: { result in
                if ((result["type"] ?? "" as AnyObject) as! String == "Payment")
                {
                    PayME.currentVC = currentVC
                    PayME.amount = result["amount"] as! Int
                    PayME.description = (result["content"] ?? "" as AnyObject) as! String
                    currentVC.navigationController?.popViewController(animated: true)
                    PayME.currentVC!.presentPanModal(Methods())
                    PayME.currentVC!.removeSpinner()

                } else {
                    let alert = UIAlertController(title: "Error", message: "Phương thức này chưa được hỗ trợ", preferredStyle: UIAlertController.Style.alert)
                    currentVC.navigationController?.popViewController(animated: true)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    PayME.currentVC!.present(alert, animated: true, completion: nil)
                    PayME.currentVC!.removeSpinner()
                }
                
            }, onError: { result in
                PayME.currentVC!.removeSpinner()
                currentVC.navigationController?.popViewController(animated: true)
                PayME.currentVC!.presentPanModal(QRNotFound())
            })
        })
        qrScan.setScanFail(onScanFail: { error in
            currentVC.navigationController?.popViewController(animated: true)
            PayME.currentVC!.presentPanModal(QRNotFound())
        })
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        currentVC.navigationController?.pushViewController(qrScan, animated: true)
    }
    
    public static func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    public init(appID: String, publicKey: String, connectToken: String, appPrivateKey: String, env: String, configColor: [String]) {
        PayME.appPrivateKey = appPrivateKey;
        PayME.appID = appID;
        PayME.connectToken = connectToken;
        PayME.publicKey = publicKey;
        PayME.env = env;
        PayME.configColor = configColor
    }
    
    public func setPrivateKey(appPrivateKey : String) {
        PayME.appPrivateKey = appPrivateKey
    }
    public func setAppID(appID : String) {
        PayME.appID = appID
    }
    public func setPublicKey(publicKey: String) {
        PayME.publicKey = publicKey
    }
    public func setAppPrivateKey(appPrivateKey: String) {
        PayME.appPrivateKey = appPrivateKey
    }
    public func getAppID() -> String {
        return PayME.appID
    }
    public func getPublicKey() -> String{
        return PayME.publicKey
    }
    public func getConnectToken() -> String{
        return PayME.connectToken
    }
    public func getAppPrivateKey() -> String {
        return PayME.appPrivateKey
    }
    public func getEnv() -> String {
        return PayME.env
    }
    public func setEnv(env: String) {
        PayME.env = env
    }
    public func isConnected() -> Bool {
        return false
    }
    public func openWallet(currentVC : UIViewController, action : Action, amount: Int?, description: String?, extraData: String?,
                           onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                           onError: @escaping (String) -> ()
    )-> () {
        let topSafeArea: CGFloat
        let bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            topSafeArea = currentVC.view.safeAreaInsets.top
            bottomSafeArea = currentVC.view.safeAreaInsets.bottom
        } else {
            topSafeArea = currentVC.topLayoutGuide.length
            bottomSafeArea = currentVC.bottomLayoutGuide.length
        }
        let data =
        """
        {"connectToken":"\(PayME.connectToken)","appToken":"\(PayME.appID)","clientInfo":{"clientId":"\(PayME.deviceID)","platform":"IOS","appVersion":"\(PayME.appVersion!)","sdkVesion":"0.1","sdkType":"IOS","appPackageName":"\(PayME.packageName!)"},"partner":{"type":"IOS","paddingTop":"\(topSafeArea)", "paddingBottom":"\(bottomSafeArea)"},"configColor":["\(PayME.handleColor(input:PayME.configColor))"],"actions":{"type":"\(action)","amount":"\(PayME.checkIntNil(input: amount))","description":"\(PayME.checkStringNil(input: description))"},"extraData":"\(PayME.checkStringNil(input:extraData))"}
        """
        let webViewController = WebViewController(nibName: "WebView", bundle: nil)
        let url = PayME.urlWebview(env: PayME.env)
        PayME.currentVC = currentVC
        webViewController.urlRequest = url + "\(data)"
        //webViewController.urlRequest = "https://tuoitre.vn/"
        webViewController.setOnSuccessCallback(onSuccess: onSuccess)
        webViewController.setOnErrorCallback(onError: onError)
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        currentVC.navigationController?.pushViewController(webViewController, animated: true)
    }
    internal static func openWalletAgain(currentVC : UIViewController, action : Action, amount: Int?, description: String?, extraData: String?
    )-> () {
        let topSafeArea: CGFloat
        let bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            topSafeArea = currentVC.view.safeAreaInsets.top
            bottomSafeArea = currentVC.view.safeAreaInsets.bottom
        } else {
            topSafeArea = currentVC.topLayoutGuide.length
            bottomSafeArea = currentVC.bottomLayoutGuide.length
        }
        let data =
        """
        {"connectToken":"\(PayME.connectToken)","appToken":"\(PayME.appID)","clientInfo":{"clientId":"\(PayME.deviceID)","platform":"IOS","appVersion":"\(PayME.appVersion!)","sdkVesion":"0.1","sdkType":"IOS","appPackageName":"\(PayME.packageName!)"},"partner":{"type":"IOS","paddingTop":"\(topSafeArea)", "paddingBottom":"\(bottomSafeArea)"},"configColor":["\(PayME.handleColor(input:PayME.configColor))"],"actions":{"type":"\(action)","amount":"\(PayME.checkIntNil(input: amount))","description":"\(PayME.checkStringNil(input: description))"},"extraData":"\(PayME.checkStringNil(input:extraData))"}
        """
        let webViewController = WebViewController(nibName: "WebView", bundle: nil)
        let url = PayME.urlWebview(env: PayME.env)
        PayME.currentVC = currentVC
        webViewController.urlRequest = url + "\(data)"
        //webViewController.urlRequest = "https://tuoitre.vn/"
        webViewController.KYCAgain = true
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        currentVC.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    public func deposit(currentVC : UIViewController, amount: Int?, description: String?, extraData: String?,
    onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
    onError: @escaping (String) -> ()) {
        let topSafeArea: CGFloat
        let bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            topSafeArea = currentVC.view.safeAreaInsets.top
            bottomSafeArea = currentVC.view.safeAreaInsets.bottom
        } else {
            topSafeArea = currentVC.topLayoutGuide.length
            bottomSafeArea = currentVC.bottomLayoutGuide.length
        }
        let data =
        """
        {"connectToken":"\(PayME.connectToken)","appToken":"\(PayME.appID)","clientInfo":{"clientId":"\(PayME.deviceID)","platform":"IOS","appVersion":"\(PayME.appVersion!)","sdkVesion":"0.1","sdkType":"IOS","appPackageName":"\(PayME.packageName!)"},"partner":{"type":"IOS","paddingTop":"\(topSafeArea)", "paddingBottom":"\(bottomSafeArea)"},"configColor":["\(PayME.handleColor(input:PayME.configColor))"],"actions":{"type":"DEPOSIT","amount":"\(PayME.checkIntNil(input: amount))","description":"\(PayME.checkStringNil(input: description))"},"extraData":"\(PayME.checkStringNil(input:extraData))"}
        """
        let webViewController = WebViewController(nibName: "WebView", bundle: nil)
        let url = PayME.urlWebview(env: PayME.env)
        PayME.currentVC = currentVC
        webViewController.urlRequest = url + "\(data)"
        webViewController.setOnSuccessCallback(onSuccess: onSuccess)
        webViewController.setOnErrorCallback(onError: onError)
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        currentVC.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    public func goToTest(currentVC : UIViewController, amount: Int?, description: String?, extraData: String?,
                     onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                     onError: @escaping (String) -> ()
    ){
        let topSafeArea: CGFloat
        let bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            topSafeArea = currentVC.view.safeAreaInsets.top
            bottomSafeArea = currentVC.view.safeAreaInsets.bottom
        } else {
            topSafeArea = currentVC.topLayoutGuide.length
            bottomSafeArea = currentVC.bottomLayoutGuide.length
        }
        let data =
        """
        {"connectToken":"\(PayME.connectToken)","appToken":"\(PayME.appID)","clientInfo":{"clientId":"\(PayME.deviceID)","platform":"IOS","appVersion":"\(PayME.appVersion!)","sdkVesion":"0.1","sdkType":"IOS","appPackageName":"\(PayME.packageName!)"},"partner":"IOS","partnerTop":"\(topSafeArea)","configColor":["\(PayME.handleColor(input:PayME.configColor))"]}
        """
        let webViewController = WebViewController(nibName: "WebView", bundle: nil)
        webViewController.urlRequest = "https://sbx-sdk.payme.com.vn/test"
        //webViewController.urlRequest = "https://tuoitre.vn/"
        webViewController.setOnSuccessCallback(onSuccess: onSuccess)
        webViewController.setOnErrorCallback(onError: onError)
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        currentVC.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    public func withdraw(currentVC : UIViewController, amount: Int?, description: String?, extraData: String?,
    onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
    onError: @escaping (String) -> ()) {
        let topSafeArea: CGFloat
        let bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            topSafeArea = currentVC.view.safeAreaInsets.top
            bottomSafeArea = currentVC.view.safeAreaInsets.bottom
        } else {
            topSafeArea = currentVC.topLayoutGuide.length
            bottomSafeArea = currentVC.bottomLayoutGuide.length
        }
        let data =
        """
        {"connectToken":"\(PayME.connectToken)","appToken":"\(PayME.appID)","clientInfo":{"clientId":"\(PayME.deviceID)","platform":"IOS","appVersion":"\(PayME.appVersion!)","sdkVesion":"0.1","sdkType":"IOS","appPackageName":"\(PayME.packageName!)"},"partner":{"type":"IOS","paddingTop":"\(topSafeArea)", "paddingBottom":"\(bottomSafeArea)"},"configColor":["\(PayME.handleColor(input:PayME.configColor))"],"actions":{"type":"WITHDRAW","amount":"\(PayME.checkIntNil(input: amount))","description":"\(PayME.checkStringNil(input: description))"},"extraData":"\(PayME.checkStringNil(input:extraData))"}
        """
        let webViewController = WebViewController(nibName: "WebView", bundle: nil)
        let url = PayME.urlWebview(env: PayME.env)
        PayME.currentVC = currentVC
        webViewController.urlRequest = url + "\(data)"
        webViewController.setOnSuccessCallback(onSuccess: onSuccess)
        webViewController.setOnErrorCallback(onError: onError)
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        currentVC.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    public func pay(currentVC : UIViewController, amount: Int, description: String?, extraData: String?) {
        PayME.currentVC = currentVC
        PayME.amount = amount
        PayME.description = description ?? ""
        PayME.currentVC!.presentPanModal(Methods())
    }
    
    
    
    private static func handleColor(input: [String]) -> String {
        let newString = input.joined(separator: "\",\"")
        return newString
    }
    private static func checkIntNil(input: Int?) -> String {
        if input != nil {
            return String(input!)
        }
        return ""
    }
    private static func checkUserInfoNil(input: UserInfo?) -> String{
        if input != nil {
            return input!.toJson()
        }
        return "{}"
    }
    private static func checkStringNil(input: String?) -> String {
        if input != nil {
            return input!
        }
        return ""
    }
    
    public static func formatMoney(input: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 3
        let temp = numberFormatter.string(from: NSNumber(value: input))
        return "\(temp!)"
    }


    private static func  urlFeENV(env: String?) -> String {
        if (env == "sandbox") {
            return "https://sbx-wam.payme.vn/v1/"
        }
        return "https://wam.payme.vn/v1/"
    }
    
    private static func  urlWebview(env: String?) -> String {
        if (env == "sandbox") {
            return "https://sbx-sdk.payme.com.vn/active/"
        }
        return "https://sdk.payme.com.vn/active/"
    }
    
    private static func urlUpload(env: String?) -> String {
        if (env == "sandbox") {
            return "https://sbx-static.payme.vn/"
        }
        return "https://static.payme.vn/"
    }
    
    public func getWalletInfo(
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping ([Int:Any]) -> ()
    ) {
        let url = PayME.urlFeENV(env: PayME.env)
        let path = "/Wallet/Information"
        let clientInfo: [String: String] = [
            "clientId": PayME.deviceID,
            "platform": "IOS",
            "appVersion": PayME.appVersion!,
            "sdkType" : "IOS",
            "sdkVesion": "0.1",
            "appPackageName": PayME.packageName!
        ]
        let data: [String: Any] = [
            "connectToken": PayME.connectToken,
            "clientInfo": clientInfo
        ]
        let params = try? JSONSerialization.data(withJSONObject: data)
        let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
        request.setOnRequestCrypto(
        onStart: {},
        onError: {(error) in
            onError(error)
        },
       onSuccess : {(response) in
            onSuccess(response)
        },
       onFinally: {}, onExpired: {})
    }
    
    public static func uploadImageKYC(
        imageFront: UIImage,
        imageBack: UIImage?,
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping ([Int:Any]) -> ()
    ) {
        let url = urlUpload(env: PayME.env)
        let path = url + "/Upload"
        let imageData = imageFront.jpegData(compressionQuality: 1)
        let headers : HTTPHeaders = ["Content-type": "multipart/form-data",
                                     "Content-Disposition" : "form-data"]
        AF.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData!, withName: "files", fileName: "imageFront.png", mimeType: "image/png")
                if (imageBack != nil) {
                    let imageDataBack = imageBack!.jpegData(compressionQuality: 1)
                    multipartFormData.append(imageDataBack!, withName: "files", fileName: "imageBack.png", mimeType: "image/png")
                }
            }, to: path, method: .post, headers: headers)
            .response { response in
                do {
                    if response.response?.statusCode == 200 {
                        let jsonData = response.data
                        let parsedData = try JSONSerialization.jsonObject(with: jsonData!) as! Dictionary<String, AnyObject>
                        onSuccess(parsedData)
                    }
                } catch {
                    onError([1001: "Some thing went wrong"])
                }
            }
    }
    public static func verifyKYC(
        imageFront: String,
        imageBack: String,
        identifyType: String,
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping ([Int:Any]) -> ()
    ) {
         let url = urlFeENV(env: PayME.env)
         let path = "/v1/Account/Kyc"
         let clientInfo: [String: String] = [
             "clientId": PayME.deviceID,
             "platform": "IOS",
             "appVersion": PayME.appVersion!,
             "sdkType" : "IOS",
             "sdkVesion": "0.1",
             "appPackageName": PayME.packageName!
         ]
         let data: [String: Any] = [
             "connectToken": PayME.connectToken,
             "clientInfo": clientInfo,
             "identifyType": identifyType,
             "image": ["front" : imageFront, "back": imageBack]
         ]
         let params = try? JSONSerialization.data(withJSONObject: data)
         let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
         request.setOnRequestCrypto(
         onStart: {},
         onError: {(error) in
             onError(error)
         },
        onSuccess : {(response) in
             onSuccess(response)
         },
        onFinally: {}, onExpired: {})
    }

    
    public static func getTransferMethods(
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping ([Int:Any]) -> ()
    ) {
        let url = urlFeENV(env: PayME.env)
        let path = "/Transfer/GetMethods"
        let clientInfo: [String: String] = [
            "clientId": PayME.deviceID,
            "platform": "IOS",
            "appVersion": PayME.appVersion!,
            "sdkType" : "IOS",
            "sdkVesion": "0.1",
            "appPackageName": PayME.packageName!
        ]
        let data: [String: Any] = [
            "connectToken": PayME.connectToken,
            "clientInfo": clientInfo
        ]
        let params = try? JSONSerialization.data(withJSONObject: data)
        let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
        request.setOnRequestCrypto(
        onStart: {},
        onError: {(error) in
            onError(error)
        },
       onSuccess : {(response) in
            onSuccess(response)
        },
       onFinally: {}, onExpired: {})
    }
    public static func postTransferAppWallet(onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
    onError: @escaping ([Int:Any]) -> ()){
         let url = urlFeENV(env: PayME.env)
         let path = "/Transfer/AppWallet/Generate"
         let clientInfo: [String: String] = [
             "clientId": PayME.deviceID,
             "platform": "IOS",
             "appVersion": PayME.appVersion!,
             "sdkType" : "IOS",
             "sdkVesion": "0.1",
             "appPackageName": PayME.packageName!
         ]
         let data: [String: Any] = [
             "connectToken": PayME.connectToken,
             "clientInfo": clientInfo,
             "amount" : PayME.amount,
             "destination" : "AppPartner",
             "data" : ["":""]
         ]
         let params = try? JSONSerialization.data(withJSONObject: data)
         let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
         request.setOnRequestCrypto(
         onStart: {},
         onError: {(error) in
             onError(error)
         },
        onSuccess : {(response) in
             onSuccess(response)
         },
        onFinally: {}, onExpired: {})
        
    }
    public static func postTransferNapas(method: MethodInfo,onSuccess: @escaping (Dictionary<String, AnyObject>) -> (), onError: @escaping ([Int:Any]) -> ()) {
         let url = urlFeENV(env: PayME.env)
         let path = "/Transfer/Napas/Generate"
         let clientInfo: [String: String] = [
             "clientId": PayME.deviceID,
             "platform": "IOS",
             "appVersion": PayME.appVersion!,
             "sdkType" : "IOS",
             "sdkVesion": "0.1",
             "appPackageName": PayME.packageName!
         ]
         let data: [String: Any] = [
             "connectToken": PayME.connectToken,
             "clientInfo": clientInfo,
             "amount" : PayME.amount,
             "destination" : "AppPartner",
             "returnUrl" : "https://sbx-fe.payme.vn/",
             "linkedId" : method.linkedId!,
             "bankCode" : method.bankCode!,
             "data" : ["":""]
         ]
         let params = try? JSONSerialization.data(withJSONObject: data)
         let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
         request.setOnRequestCrypto(
         onStart: {},
         onError: {(error) in
             onError(error)
         },
        onSuccess : {(response) in
             onSuccess(response)
         },
        onFinally: {}, onExpired: {})
    }
    public static func postTransferPVCB(method: MethodInfo,onSuccess: @escaping (Dictionary<String, AnyObject>) -> (), onError: @escaping ([Int:Any]) -> ()) {
         let url = urlFeENV(env: PayME.env)
         let path = "/Transfer/PVCBank/Generate"
         let clientInfo: [String: String] = [
             "clientId": PayME.deviceID,
             "platform": "IOS",
             "appVersion": PayME.appVersion!,
             "sdkType" : "IOS",
             "sdkVesion": "0.1",
             "appPackageName": PayME.packageName!
         ]
         let data: [String: Any] = [
             "connectToken": PayME.connectToken,
             "clientInfo": clientInfo,
             "amount" : PayME.amount,
             "destination" : "AppPartner",
             "linkedId" : method.linkedId!,
             "data" : ["":""]
         ]
         let params = try? JSONSerialization.data(withJSONObject: data)
         let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
         request.setOnRequestCrypto(
         onStart: {},
         onError: {(error) in
             onError(error)
         },
        onSuccess : {(response) in
             onSuccess(response)
         },
        onFinally: {}, onExpired: {})
    }
    
    public static func postTransferPVCBVerify(transferId:Int, OTP:String, onSuccess: @escaping (Dictionary<String, AnyObject>) -> (), onError: @escaping ([Int:Any]) -> ()){
        let url = urlFeENV(env: PayME.env)
         let path = "/Transfer/PVCBank/Verify"
         let clientInfo: [String: String] = [
             "clientId": PayME.deviceID,
             "platform": "IOS",
             "appVersion": PayME.appVersion!,
             "sdkType" : "IOS",
             "sdkVesion": "0.1",
             "appPackageName": PayME.packageName!
         ]
         let data: [String: Any] = [
             "connectToken": PayME.connectToken,
             "clientInfo": clientInfo,
             "transferId" : transferId,
             "destination" : "AppPartner",
             "OTP" : OTP,
             "data" : ["":""]
         ]
         let params = try? JSONSerialization.data(withJSONObject: data)
         let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
         request.setOnRequestCrypto(
         onStart: {},
         onError: {(error) in
             onError(error)
         },
        onSuccess : {(response) in
             onSuccess(response)
         },
        onFinally: {}, onExpired: {})
    }
    public static func payWithQRCode(QRContent: String, onSuccess: @escaping (Dictionary<String, AnyObject>) -> (), onError: @escaping ([Int:Any]) -> ()){
         let url = urlFeENV(env: PayME.env)
         let path = "/Pay/PayWithQRCode"
         let clientInfo: [String: String] = [
             "clientId": PayME.deviceID,
             "platform": "IOS",
             "appVersion": PayME.appVersion!,
             "sdkType" : "IOS",
             "sdkVesion": "0.1",
             "appPackageName": PayME.packageName!
         ]
         let data: [String: Any] = [
             "connectToken": PayME.connectToken,
             "clientInfo": clientInfo,
             "data" : QRContent
         ]
         let params = try? JSONSerialization.data(withJSONObject: data)
         let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
         request.setOnRequestCrypto(
         onStart: {},
         onError: {(error) in
             onError(error)
         },
        onSuccess : {(response) in
             onSuccess(response)
         },
        onFinally: {}, onExpired: {})
    }
    public static func generateConnectToken(usertId: String, phoneNumber: String?, timestamp: String, onSuccess: @escaping (Dictionary<String, AnyObject>) -> (), onError: @escaping ([Int:Any]) -> ()){
         let url = urlFeENV(env: PayME.env)
         let path = "/Internal/ConnectToken/Generate"
         let data: [String: Any] = [
            "userId" : usertId,
            "phone" : phoneNumber ?? "",
            "timestamp": timestamp
         ]
         let params = try? JSONSerialization.data(withJSONObject: data)
         let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
         request.setOnRequestCrypto(
         onStart: {},
         onError: {(error) in
             onError(error)
         },
        onSuccess : {(response) in
             onSuccess(response)
         },
        onFinally: {}, onExpired: {})
    }
}

