//
//  ViewController.swift
//  PayMESDK
//
//  Created by HuyOpen on 10/19/2020.
//  Copyright (c) 2020 HuyOpen. All rights reserved.
//

import UIKit
import PayMESDK

class ViewController: UIViewController{
    
    var payME : PayME?
    var activeTextField : UITextField? = nil
    
    let balance: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(12)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Balance"
        return label
    }()
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        return label
    }()
    let userIDLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "User ID"
        return label
    }()
    
    let userIDTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "required"
        textField.setLeftPaddingPoints(10)
        textField.keyboardType = .numberPad
        return textField
    }()
    let phoneLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Phone Number"
        return label
    }()
    
    let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "required"
        textField.setLeftPaddingPoints(10)
        textField.keyboardType = .numberPad
        return textField
    }()
    
    let submitButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.setTitle("Create Connect Token", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let openWalletButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.setTitle("Mở SDK", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let depositButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.setTitle("Nạp tiền ví", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let moneyDeposit: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Nhập số tiền"
        textField.setLeftPaddingPoints(10)
        textField.keyboardType = .numberPad
        return textField
    }()
    
    let withDrawButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.setTitle("Rút tiền ví", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let moneyWithDraw: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Nhập số tiền"
        textField.setLeftPaddingPoints(10)
        textField.keyboardType = .numberPad
        return textField
    }()
    
    let payButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.setTitle("Thanh toán", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let moneyPay: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Nhập số tiền"
        textField.setLeftPaddingPoints(10)
        textField.keyboardType = .numberPad
        return textField
    }()
    
    let refreshButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "refresh.png"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let PUBLIC_KEY: String = "MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKWcehEELB4GdQ4cTLLQroLqnD3AhdKi\nwIhTJpAi1XnbfOSrW/Ebw6h1485GOAvuG/OwB+ScsfPJBoNJeNFU6J0CAwEAAQ==\n"
    private let PRIVATE_KEY: String = "MIIBPAIBAAJBAKWcehEELB4GdQ4cTLLQroLqnD3AhdKiwIhTJpAi1XnbfOSrW/Eb\nw6h1485GOAvuG/OwB+ScsfPJBoNJeNFU6J0CAwEAAQJBAJSfTrSCqAzyAo59Ox+m\nQ1ZdsYWBhxc2084DwTHM8QN/TZiyF4fbVYtjvyhG8ydJ37CiG7d9FY1smvNG3iDC\ndwECIQDygv2UOuR1ifLTDo4YxOs2cK3+dAUy6s54mSuGwUeo4QIhAK7SiYDyGwGo\nCwqjOdgOsQkJTGoUkDs8MST0MtmPAAs9AiEAjLT1/nBhJ9V/X3f9eF+g/bhJK+8T\nKSTV4WE1wP0Z3+ECIA9E3DWi77DpWG2JbBfu0I+VfFMXkLFbxH8RxQ8zajGRAiEA\n8Ly1xJ7UW3up25h9aa9SILBpGqWtJlNQgfVKBoabzsU=\n"
    private let appID: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MX0.wNtHVZ-olKe7OAkgLigkTSsLVQKv_YL9fHKzX9mn9II"
    private var  connectToken: String = ""
    
    // generate token ( demo, don't apply this to your code, generate from your server)
    @objc func submit(sender: UIButton!) {
        //PayME.showKYCCamera(currentVC: self)
        if (userIDTextField.text != "") {
            let formatter = ISO8601DateFormatter()
            self.payME = PayME(appID: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MX0.wNtHVZ-olKe7OAkgLigkTSsLVQKv_YL9fHKzX9mn9II", publicKey: PUBLIC_KEY, connectToken: self.connectToken, appPrivateKey: PRIVATE_KEY, env:"sandbox", configColor: ["#75255b", "#a81308"])
            let timestamp = formatter.string(from: Date())
            PayME.generateConnectToken(usertId: userIDTextField.text!, phoneNumber: phoneTextField.text, timestamp: timestamp, onSuccess: { response in
                self.connectToken = response["connectToken"] as! String
                let alert = UIAlertController(title: "Success", message: "Tạo token thành công", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }, onError: { error in
                self.connectToken = ""
                var errorToken = "Something went wrong"
                error.values.forEach{ value in
                    let data = value as! [String:AnyObject]
                    errorToken = data["message"] as! String
                }
                let alert = UIAlertController(title: "Error", message: errorToken, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    @objc func openWalletAction(sender: UIButton!) {
        if (self.connectToken != "") {
            var payME = PayME(appID: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MX0.wNtHVZ-olKe7OAkgLigkTSsLVQKv_YL9fHKzX9mn9II", publicKey: PUBLIC_KEY, connectToken: self.connectToken, appPrivateKey: PRIVATE_KEY, env:"sandbox", configColor: ["#75255b", "#a81308"])
            payME.openWallet(currentVC: self, action: PayME.Action.OPEN, amount: nil, description: nil, extraData: nil, onSuccess: {a in }, onError: {a in})
        } else {
            let alert = UIAlertController(title: "Error", message: "Vui lòng tạo connect token trước", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func depositAction(sender: UIButton!) {
        if (self.connectToken != "") {
            if (moneyDeposit.text != "") {
                let amount = Int(moneyDeposit.text!)
                if (amount! >= 10000){
                    let amountDeposit = amount!
                    var payME = PayME(appID: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MX0.wNtHVZ-olKe7OAkgLigkTSsLVQKv_YL9fHKzX9mn9II", publicKey: PUBLIC_KEY, connectToken: self.connectToken, appPrivateKey: PRIVATE_KEY, env:"sandbox", configColor: ["#75255b", "#a81308"])
                    payME.deposit(currentVC: self, amount: amountDeposit, description: "", extraData: nil, onSuccess: {a in print(a)}, onError: {a in print(a)})

                } else {
                    let alert = UIAlertController(title: "Error", message: "Vui lòng nạp hơn 10.000VND", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Vui lòng nạp hơn 10.000VND", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            
        } else {
            let alert = UIAlertController(title: "Error", message: "Vui lòng tạo connect token trước", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func withDrawAction(sender: UIButton!) {
        if (self.connectToken != "") {
            if (moneyWithDraw.text != "") {
                let amount = Int(moneyWithDraw.text!)
                if (amount! >= 10000){
                    let amountWithDraw = amount!
                    var payME = PayME(appID: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MX0.wNtHVZ-olKe7OAkgLigkTSsLVQKv_YL9fHKzX9mn9II", publicKey: PUBLIC_KEY, connectToken: self.connectToken, appPrivateKey: PRIVATE_KEY, env:"sandbox", configColor: ["#75255b", "#a81308"])
                    payME.withdraw(currentVC: self, amount: amountWithDraw, description: "", extraData: nil, onSuccess: {a in print(a)}, onError: {a in print(a)})
                } else {
                    let alert = UIAlertController(title: "Error", message: "Vui lòng rút hơn 10.000VND", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Vui lòng rút hơn 10.000VND", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Vui lòng tạo connect token trước", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func payAction(sender: UIButton!) {
        if (self.connectToken != "") {
            if (moneyPay.text != "") {
                let amount = Int(moneyPay.text!)
                if (amount! >= 10000){
                    var payME = PayME(appID: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MX0.wNtHVZ-olKe7OAkgLigkTSsLVQKv_YL9fHKzX9mn9II", publicKey: PUBLIC_KEY, connectToken: self.connectToken, appPrivateKey: PRIVATE_KEY, env:"sandbox", configColor: ["#75255b", "#a81308"])
                    let amountPay = amount!
                    payME.pay(currentVC: self, amount: amountPay, description: "", extraData: nil)
                } else {
                    let alert = UIAlertController(title: "Error", message: "Vui lòng thanh toán hơn 10.000VND", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Vui lòng thanh toán hơn 10.000VND", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            
        } else {
            let alert = UIAlertController(title: "Error", message: "Vui lòng tạo connect token trước", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func getBalance(_ sender: Any) {
        if (self.connectToken != "") {
            var payME = PayME(appID: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MX0.wNtHVZ-olKe7OAkgLigkTSsLVQKv_YL9fHKzX9mn9II", publicKey: PUBLIC_KEY, connectToken: self.connectToken, appPrivateKey: PRIVATE_KEY, env:"sandbox", configColor: ["#75255b", "#a81308"])
            payME.getWalletInfo(onSuccess: {a in
                var str = ""
                if let v = a["walletBalance"]!["balance"]! {
                   str = "\(v)"
                }
                self.priceLabel.text = str
                
            }, onError: {error in
                var errorToken = "Something went wrong"
                error.values.forEach{ value in
                    let data = value as! [String:AnyObject]
                    errorToken = data["message"] as! String
                }
                let alert = UIAlertController(title: "Error", message: errorToken, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.priceLabel.text = "0"
                self.present(alert, animated: true, completion: nil)
            })
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Vui lòng tạo connect token trước", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //For mobile numer validation
        if textField == phoneTextField || textField == moneyDeposit || textField == moneyWithDraw || textField == moneyPay {
            let allowedCharacters = CharacterSet(charactersIn:"+0123456789 ")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {

          // if keyboard size is not available for some reason, dont do anything
          return
        }

        var shouldMoveViewUp = false

        // if active text field is not nil
        if let activeTextField = activeTextField {

          let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
          
          let topOfKeyboard = self.view.frame.height - keyboardSize.height

          // if the bottom of Textfield is below the top of keyboard, move up
          if bottomOfTextField > topOfKeyboard {
            shouldMoveViewUp = true
          }
        }

        if(shouldMoveViewUp) {
          self.view.frame.origin.y = 0 - keyboardSize.height
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        self.view.addSubview(balance)
        self.view.addSubview(priceLabel)
        self.view.addSubview(userIDLabel)
        self.view.addSubview(userIDTextField)
        self.view.addSubview(phoneLabel)
        self.view.addSubview(phoneTextField)
        self.view.addSubview(submitButton)
        self.view.addSubview(openWalletButton)
        self.view.addSubview(depositButton)
        self.view.addSubview(moneyDeposit)
        self.view.addSubview(withDrawButton)
        self.view.addSubview(moneyWithDraw)
        self.view.addSubview(payButton)
        self.view.addSubview(moneyPay)
        self.view.addSubview(refreshButton)
        phoneTextField.delegate = self
        moneyDeposit.delegate = self
        moneyWithDraw.delegate = self
        moneyPay.delegate = self
        
        balance.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        balance.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50).isActive = true
        
        priceLabel.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        priceLabel.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: -20).isActive = true
        
        refreshButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        refreshButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        refreshButton.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 8).isActive = true
        refreshButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        refreshButton.addTarget(self, action: #selector(getBalance(_:)), for: .touchUpInside)
        
        userIDLabel.topAnchor.constraint(equalTo: balance.bottomAnchor, constant: 30).isActive = true
        userIDLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50).isActive = true
        
        userIDTextField.topAnchor.constraint(equalTo: userIDLabel.bottomAnchor, constant: 10).isActive = true
        userIDTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50).isActive = true
        userIDTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        userIDTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        phoneLabel.topAnchor.constraint(equalTo: userIDLabel.bottomAnchor, constant: 50).isActive = true
        phoneLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50).isActive = true
        
        phoneTextField.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 10).isActive = true
        phoneTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50).isActive = true
        phoneTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        phoneTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        // Do any additional setup after loading the view.
        submitButton.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 10).isActive = true
        submitButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50).isActive = true
        submitButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        submitButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        
        openWalletButton.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 10).isActive = true
        openWalletButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50).isActive = true
        openWalletButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        openWalletButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        openWalletButton.addTarget(self, action: #selector(openWalletAction), for: .touchUpInside)
        
        depositButton.topAnchor.constraint(equalTo: openWalletButton.bottomAnchor, constant: 10).isActive = true
        depositButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50).isActive = true
        depositButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        depositButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        depositButton.addTarget(self, action: #selector(depositAction), for: .touchUpInside)

        moneyDeposit.topAnchor.constraint(equalTo: openWalletButton.bottomAnchor, constant: 10).isActive = true
        moneyDeposit.leadingAnchor.constraint(equalTo: depositButton.trailingAnchor, constant: 5).isActive = true
        moneyDeposit.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        moneyDeposit.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        withDrawButton.topAnchor.constraint(equalTo: depositButton.bottomAnchor, constant: 10).isActive = true
        withDrawButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50).isActive = true
        withDrawButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        withDrawButton.heightAnchor.constraint(equalToConstant: 35).isActive = true

        moneyWithDraw.topAnchor.constraint(equalTo: depositButton.bottomAnchor, constant: 10).isActive = true
        moneyWithDraw.leadingAnchor.constraint(equalTo: withDrawButton.trailingAnchor, constant: 5).isActive = true
        moneyWithDraw.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        moneyWithDraw.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        withDrawButton.addTarget(self, action: #selector(withDrawAction), for: .touchUpInside)
        
        payButton.topAnchor.constraint(equalTo: withDrawButton.bottomAnchor, constant: 10).isActive = true
        payButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50).isActive = true
        payButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        payButton.heightAnchor.constraint(equalToConstant: 35).isActive = true

        moneyPay.topAnchor.constraint(equalTo: withDrawButton.bottomAnchor, constant: 10).isActive = true
        moneyPay.leadingAnchor.constraint(equalTo: payButton.trailingAnchor, constant: 5).isActive = true
        moneyPay.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        moneyPay.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        payButton.addTarget(self, action: #selector(payAction), for: .touchUpInside)

        
    }
    
}
extension ViewController : UITextFieldDelegate {
  // when user select a textfield, this method will be called
  func textFieldDidBeginEditing(_ textField: UITextField) {
    // set the activeTextField to the selected textfield
    self.activeTextField = textField
  }
    
  // when user click 'done' or dismiss the keyboard
  func textFieldDidEndEditing(_ textField: UITextField) {
    self.activeTextField = nil
  }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
