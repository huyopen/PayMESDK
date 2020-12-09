//
//  ViewController.swift
//  One Time Code
//
//  Created by Kyle Lee on 5/25/19.
//  Copyright © 2019 Kilo Loco. All rights reserved.
//

import UIKit

class OTP: UIViewController, PanModalPresentable {
    
    static var transferId: Int? = nil
    
    private static var onError: ((Dictionary<Int, Any>) -> ())? = nil
    
    private static var onSuccess: ((Dictionary<String, AnyObject>) -> ())? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(nameLabel)
        view.addSubview(roleLabel)
        view.addSubview(button)
        view.addSubview(image)
        view.addSubview(closeButton)
        view.addSubview(txtLabel)
        view.addSubview(txtField)
        txtLabel.text = "Xác thực OTP"
        roleLabel.text = "Vui lòng nhập mã OTP được gửi tới số 09833411111"
        button.setTitle("Xác nhận", for: .normal)
        roleLabel.lineBreakMode = .byWordWrapping
        roleLabel.numberOfLines = 0
        roleLabel.textAlignment = .center
        setupConstraints()
        txtField.becomeFirstResponder()
        self.hideKeyboardWhenTappedAround()

        NotificationCenter.default.addObserver(self, selector: #selector(OTP.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OTP.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    var longFormHeight: PanModalHeight {
        return .intrinsicHeight
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {

          // if keyboard size is not available for some reason, dont do anything
          return
        }
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: button.bottomAnchor, constant: keyboardSize.height).isActive = true
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
        
    }
    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: button.bottomAnchor).isActive = true
      panModalSetNeedsLayoutUpdate()
        
    }
    

    var anchorModalToLongForm: Bool {
        return false
    }

    var shouldRoundTopCorners: Bool {
        return true
    }
    
    func setupConstraints() {
        txtLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 19).isActive = true
        txtLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 19).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        
        image.topAnchor.constraint(equalTo: txtLabel.topAnchor, constant: 30).isActive = true
        image.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        roleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        roleLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10).isActive = true
        roleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        roleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.topAnchor.constraint(equalTo: txtField.bottomAnchor, constant: 20).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        txtField.topAnchor.constraint(equalTo: roleLabel.bottomAnchor).isActive = true
        txtField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: button.bottomAnchor, constant: 10).isActive = true
        txtField.didEnterLastDigit = { [self] code in
            self.txtField.showSpinner(onView: PayME.currentVC!.view)
            PayME.postTransferPVCBVerify(transferId: OTP.transferId!, OTP: code, onSuccess: { onSuccess in
                self.txtField.removeSpinner()
                PayME.currentVC!.dismiss(animated: true)
                PayME.currentVC!.presentPanModal(Success())
            }, onError: { error in
                print(1008)
                print(error)
                if (error[1008] != nil) {
                    var message = "Mã OTP không hợp lệ. Vui lòng thử lại."
                    error.values.forEach{ value in
                        let data = value as! [String:AnyObject]
                        message = data["message"] as! String
                    }
                    let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let failController = Failed()
                self.txtField.removeSpinner()
                error.values.forEach{ value in
                    let data = value as! [String:AnyObject]
                    failController.reasonFail = data["message"] as! String
                }
                PayME.currentVC!.dismiss(animated: true)
                PayME.currentVC!.presentPanModal(failController)
                
            })
        }
    }
    
    @objc
    func buttonAction(button:UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    public static func setSuccess(onSuccess: @escaping (Dictionary<String, AnyObject>) -> ()) {
        OTP.onSuccess = onSuccess
    }
    public static func setError(onError: @escaping (Dictionary<Int, Any>) -> ()) {
        OTP.onError = onError
    }
    
    let txtField : OneTimeCodeTextField = {
        let txtField = OneTimeCodeTextField()
        txtField.defaultCharacter = "-"
        txtField.configure()
        txtField.didEnterLastDigit = { [self] code in
            txtField.showSpinner(onView: PayME.currentVC!.view)
            PayME.postTransferPVCBVerify(transferId: OTP.transferId!, OTP: code, onSuccess: { onSuccess in
                txtField.removeSpinner()
                PayME.currentVC!.dismiss(animated: true)
                PayME.currentVC!.presentPanModal(Success())
            }, onError: {[self] error in
                print(1008)
                print(error)
                if (error[1008] != nil) {
                    error.values.forEach{ value in
                        let data = value as! [String:AnyObject]
                    }
                    
                }
                let failController = Failed()
                txtField.removeSpinner()
                error.values.forEach{ value in
                    let data = value as! [String:AnyObject]
                    failController.reasonFail = data["message"] as! String
                }
                PayME.currentVC!.dismiss(animated: true)
                PayME.currentVC!.presentPanModal(failController)
                
            })
        }
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    let closeButton : UIButton = {
        let button = UIButton()
        let bundle = Bundle(for: QRNotFound.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "16Px", in: resourceBundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let image: UIImageView = {
        let bundle = Bundle(for: QRNotFound.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "touchId", in: resourceBundle, compatibleWith: nil)
        var bgImage = UIImageView(image: image)
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()
    
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(24,26,65)
        label.font = UIFont(name: "Lato-Bold", size: 25)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let roleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(115,115,115)
        label.backgroundColor = .clear
        label.font = UIFont(name: "Lato-Regular", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let button : UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(8,148,31)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        return button
    }()
    
    let txtLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor(26,26,26)
        label.backgroundColor = .clear
        label.font = UIFont(name: "Lato-SemiBold", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLayoutSubviews() {
        button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var panScrollable: UIScrollView? {
        return nil
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




