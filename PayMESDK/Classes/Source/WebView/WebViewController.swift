//
//  WebViewController.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import UIKit
import  WebKit

class WebViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate, PanModalPresentable{
    var KYCAgain : Bool? = nil
    
    var panScrollable: UIScrollView? {
        return nil
    }

    var topOffset: CGFloat {
        return 0.0
    }

    var springDamping: CGFloat {
        return 1.0
    }

    var transitionDuration: Double {
        return 0.4
    }

    var transitionAnimationOptions: UIView.AnimationOptions {
        return [.allowUserInteraction, .beginFromCurrentState]
    }

    var shouldRoundTopCorners: Bool {
        return false
    }

    var showDragIndicator: Bool {
        return false
    }
    /*
     var urlRequest : String = ""
     var webView : WKWebView!
     var mNativeToWebHandler : String = "callBackFromJS"
     
     override func loadView() {
     let userController: WKUserContentController = WKUserContentController()
     userController.add(self, name: mNativeToWebHandler)
     let config = WKWebViewConfiguration()
     config.userContentController = userController
     webView = WKWebView(frame: .zero, configuration: config)
     webView.uiDelegate = self
     view = webView
     }
     
     func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
     if message.name == "callBackFromJS", let messageBody = message.body as? String {
     print("message.body:\(messageBody)")
     }
     }
     
     override func viewDidLoad() {
     self.navigationItem.hidesBackButton = true
     let urlString = urlRequest.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
     print(urlString)
     let  myURL = URL(string: urlString!)
     let myRequest : URLRequest
     if myURL != nil
     {
     myRequest = URLRequest(url: myURL!)
     } else {
     myRequest = URLRequest(url: URL(string: "https://www.google.com/")!)
     }
     let appVersion = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
     print(appVersion)
     print(1111)
     webView.load(myRequest)
     }
     */
    
    var vc : UIImagePickerController!
    var urlRequest : String = ""
    var webView : WKWebView!
    var onCommunicate: String = "onCommunicate"
    var onClose: String = "onClose"
    var openCamera : String = "openCamera"
    var onErrorBack : String = "onError"
    var onPay : String = "onPay"
    var form = ""
    var imageFront : UIImage?
    var imageBack : UIImage?
    
    /*let content = """
          <!DOCTYPE html><html><body>
          <button onclick="onClick()">Click me</button>
          <script>
          function onClick() {
            window.webkit.messageHandlers.onCommunicate.postMessage({huy: "123", hieu: 1});
            window.webkit.messageHandlers.onClose.postMessage("success");
          }
          </script>
          </body></html>
          """
     */
    
    private var onSuccessWebView: ((String) -> ())? = nil
    private var onFailWebView: ((String) -> ())? = nil

    private var onSuccess: ((Dictionary<String, AnyObject>) -> ())? = nil
    private var onError: ((String) -> ())? = nil
    
    override func loadView() {
        let userController: WKUserContentController = WKUserContentController()
        userController.add(self, name: onCommunicate)
        userController.add(self, name: onClose)
        userController.add(self, name: openCamera)
        userController.add(self, name: onErrorBack)
        userController.add(self, name: onPay)
        userController.addUserScript(self.getZoomDisableScript())
        
        let config = WKWebViewConfiguration()
        config.userContentController = userController
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.showSpinner(onView: PayME.currentVC!.view)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.removeSpinner()
    }
    private func getZoomDisableScript() -> WKUserScript {
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum- scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
        return WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }
    
    /*override func viewDidLoad() {
        webView.loadHTMLString(content, baseURL: nil)
    }
    */
    
     override func viewDidLoad() {
        if (KYCAgain != nil && KYCAgain == true)
        {
            guard let navigationController = self.navigationController else { return }
            var navigationArray = navigationController.viewControllers
            navigationArray.remove(at: navigationArray.count-2)
            navigationArray.remove(at: navigationArray.count-2)
            navigationArray.remove(at: navigationArray.count-2)
            navigationArray.remove(at: navigationArray.count-2)
            navigationArray.remove(at: navigationArray.count-2)
            self.navigationController?.viewControllers = navigationArray
        }
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
            for record in records {
                if record.displayName.contains("payme.com.vn") {
                    dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [record], completionHandler: {
                        
                    })
                }
            }
        }
        if #available(iOS 9.0, *) {
          let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
          let date = NSDate(timeIntervalSince1970: 0)
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
        } else {
            var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
            libraryPath += "/Cookies"

            do {
                try FileManager.default.removeItem(atPath: libraryPath)
            } catch {
              print("error")
            }
            URLCache.shared.removeAllCachedResponses()
        }
        if(self.form == "")
        {
            let urlString = urlRequest.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let  myURL = URL(string: urlString!)
            let myRequest : URLRequest
            if myURL != nil
            {
                myRequest = URLRequest(url: myURL!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
            } else {
                myRequest = URLRequest(url: URL(string: "http://localhost:3000/")!)
            }
            print(myRequest)
            
            if #available(iOS 11.0, *) {
                webView.scrollView.contentInsetAdjustmentBehavior = .never;
            } else {
                self.automaticallyAdjustsScrollViewInsets = false;
            }
            webView.scrollView.alwaysBounceVertical = false
            webView.scrollView.bounces = false
            webView.load(myRequest)
        } else {
            if #available(iOS 11.0, *) {
                webView.scrollView.contentInsetAdjustmentBehavior = .never;
            } else {
                self.automaticallyAdjustsScrollViewInsets = false;
            }
            webView.scrollView.alwaysBounceVertical = false
            webView.scrollView.bounces = false
            webView.loadHTMLString(self.form, baseURL: nil)
        }
     }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (self.form != "") {
            print("URL:", navigationAction.request.url)
            if (navigationAction.request.url != nil)
            {
                let host = navigationAction.request.url!.host ?? ""
                print(host)
                //if (navigationAction.request.url!.host!) {
                if (host == "sbx-fe.payme.vn") {
                    let params = navigationAction.request.url!.queryParameters ?? ["":""]
                    if (params["success"] == "true") {
                        self.onSuccessWebView!("success")
                        decisionHandler(.cancel)
                        return
                    }
                    if (params["success"] == "false") {
                        self.onFailWebView!(params["message"]!)
                        decisionHandler(.cancel)
                        return
                    }
                    decisionHandler(.allow)

                } else {
                    decisionHandler(.allow)
                }

            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == openCamera {
            setupCamera()
        }
        if message.name == onCommunicate {
            if let dictionary = message.body as? [String: AnyObject] {
                self.onSuccess!(dictionary)
            }
        }
        if message.name == onErrorBack {
            if let dictionary = message.body as? [String: AnyObject] {
                if let b = dictionary["message"] as? String {
                    self.onError!(b)
                } else {
                    self.onError!("Đã có lỗi xảy ra")
                }
            }
        }
        if message.name == onClose {
            self.onCloseWebview()
        }
        if message.name == onPay {
            PayME.openQRCode(currentVC: self)
        }
    }
    

    func setupCamera() {
        let kycCameraController = KYCCameraController()
        kycCameraController.setSuccessCapture(onSuccessCapture: { response in
            print(response)
            let kycFront = KYCFrontController()
            kycFront.kycImage = response
            self.navigationController?.pushViewController(kycFront, animated: false)

            //self.webView?.evaluateJavaScript("document.getElementById('ImageReview').src='\(response)'") { (result, error) in
                //print(result)
            //}
            //self.navigationController?.popViewController(animated: true)
            /*PayME.uploadImageKYC(imageFront: response, imageBack: nil, onSuccess: { a in
                print(a)
            }, onError: { b in
                print(b)
            })
             */
        })

        navigationController?.pushViewController(kycCameraController, animated: false)
    }
    
    

    
    func onCloseWebview() {
        self.navigationController?.popViewController(animated: true)
    }
    
    public func setOnSuccessCallback(onSuccess: @escaping (Dictionary<String, AnyObject>) -> ()) {
        self.onSuccess = onSuccess
    }
    public func setOnSuccessWebView(onSuccessWebView: @escaping (String) -> ()){
        self.onSuccessWebView = onSuccessWebView
    }
    public func setOnFailWebView(onFailWebView: @escaping (String) -> ()){
        self.onFailWebView = onFailWebView
    }
    public func setOnErrorCallback(onError: @escaping (String) -> ()) {
        self.onError = onError
    }
}



