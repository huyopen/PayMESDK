//
//  Methods.swift
//  PayMESDK
//
//  Created by HuyOpen on 10/28/20.
//

import UIKit

class Methods: UINavigationController, PanModalPresentable, UITableViewDelegate,  UITableViewDataSource {

    var data : [MethodInfo] = []
    var active = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(button)
        view.addSubview(closeButton)
        view.addSubview(txtLabel)
        view.addSubview(detailView)
        view.addSubview(methodTitle)
        view.addSubview(tableView)
        detailView.addSubview(price)
        detailView.backgroundColor = UIColor(8,148,31)
        detailView.addSubview(contentLabel)
        detailView.addSubview(memoLabel)
        txtLabel.text = "Xác nhận thanh toán"
        price.text = "\(PayME.formatMoney(input: PayME.amount)) đ"
        contentLabel.text = "Nội dung"
        if (PayME.description == "") {
            memoLabel.text = "Không có nội dung"
        } else {
            memoLabel.text = PayME.description
        }
        methodTitle.text = "Chọn nguồn thanh toán"
        button.setTitle("Xác nhận", for: .normal)
        setupConstraints()
        tableView.register(Method.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        self.showSpinner(onView: PayME.currentVC!.view)
        PayME.getTransferMethods(onSuccess: {response in
            // Update UI
            let items = response["items"]! as! [[String:AnyObject]]
            var responseData : [MethodInfo] = []
            for i in 0..<items.count {
                print(items)
                if (i == 0) {
                    var temp = MethodInfo(amount: items[i]["amount"] as? Int, bankCode: items[i]["bankCode"] as? String, cardNumber: items[i]["cardNumber"] as? String, detail: items[i]["detail"] as? String, linkedId: items[i]["linkedId"] as? Int, swiftCode: items[i]["swiftCode"] as? String, type: items[i]["type"] as! String, active: true)
                    responseData.append(temp)
                } else {
                    var temp = MethodInfo(amount: items[i]["amount"] as? Int, bankCode: items[i]["bankCode"] as? String, cardNumber: items[i]["cardNumber"] as? String, detail: items[i]["detail"] as? String, linkedId: items[i]["linkedId"] as? Int, swiftCode: items[i]["swiftCode"] as? String, type: items[i]["type"] as! String, active: false)
                    responseData.append(temp)
                }
            }
            
   
             DispatchQueue.main.async {
                self.removeSpinner()
                self.data = responseData
                self.tableView.reloadData()
                self.tableView.heightAnchor.constraint(equalToConstant: self.tableView.contentSize.height).isActive = true
                self.tableView.alwaysBounceVertical = false
                self.tableView.isScrollEnabled = false
                self.view.layoutIfNeeded()
                self.panModalSetNeedsLayoutUpdate()
                self.panModalTransition(to: .shortForm)
             }
            
        },
                                 
         onError: {error in
            self.removeSpinner()
            print(error)
        })
    }

    
    var longFormHeight: PanModalHeight {
        return .intrinsicHeight
    }

    var anchorModalToLongForm: Bool {
        return false
    }

    var shouldRoundTopCorners: Bool {
        return true
    }
    
    func setupConstraints() {
        detailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        detailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        detailView.heightAnchor.constraint(equalToConstant: 118.0).isActive = true
        detailView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        detailView.topAnchor.constraint(equalTo: txtLabel.bottomAnchor, constant: 16.0).isActive = true
        
        price.topAnchor.constraint(equalTo: detailView.topAnchor, constant: 15).isActive = true
        price.centerXAnchor.constraint(equalTo: detailView.centerXAnchor).isActive = true
        
        contentLabel.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -15).isActive = true
        contentLabel.leadingAnchor.constraint(equalTo: detailView.leadingAnchor, constant: 30).isActive = true
        contentLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        contentLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        memoLabel.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -15).isActive = true
        memoLabel.leadingAnchor.constraint(equalTo: contentLabel.trailingAnchor, constant: 30).isActive = true
        memoLabel.trailingAnchor.constraint(equalTo: detailView.trailingAnchor, constant: -30).isActive = true
        memoLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        memoLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        methodTitle.topAnchor.constraint(equalTo: detailView.bottomAnchor, constant: 10).isActive = true
        methodTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        
        txtLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 19).isActive = true
        txtLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        /*
        tableView.topAnchor.constraint(equalTo: methodTitle.topAnchor, constant: 10).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        */

        tableView.topAnchor.constraint(equalTo: methodTitle.bottomAnchor, constant: 10).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        tableView.alwaysBounceVertical = false

        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 19).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true

        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        button.addTarget(self, action: #selector(payAction), for: .touchUpInside)
        
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: button.bottomAnchor, constant: 10).isActive = true
        
        
    }
    
    override func viewDidLayoutSubviews() {
        let topPoint = CGPoint(x: detailView.frame.minX+10, y: detailView.bounds.midY + 15)
        let bottomPoint = CGPoint(x: detailView.frame.maxX-10, y: detailView.bounds.midY + 15)
        detailView.createDashedLine(from: topPoint, to: bottomPoint, color: UIColor(203,203,203), strokeLength: 3, gapLength: 4, width: 0.5)
        button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)
        detailView.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 0)
    }
    
    @objc
    func closeAction(button:UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func payAction(button:UIButton)
    {
        if(data.count <= 0) {
            let alert = UIAlertController(title: "Error", message: "Không tồn tài phương thức thanh toán, vui lòng kích hoạt ví", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if(data[active].type == "AppWallet") {
            if(PayME.amount < 10000) {
                let alert = UIAlertController(title: "Error", message: "Số tiền tối thiểu để thực hiện giao dịch là 10.000VND", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            if(PayME.amount > 10000000) {
                let alert = UIAlertController(title: "Error", message: "Số tiền tối đa để thực hiện giao dịch là 10.000.000VND", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            if(PayME.amount > data[active].amount!) {
                let alert = UIAlertController(title: "Error", message: "Số dư trong ví không đủ để thực hiện giao dịch này", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.showSpinner(onView: PayME.currentVC!.view)
            PayME.postTransferAppWallet(
            onSuccess:{response in
                self.removeSpinner()
                self.dismiss(animated: true)
                PayME.currentVC!.presentPanModal(Success())
                
            },
            onError: {error in
                self.removeSpinner()
                self.dismiss(animated: true)
                let failController = Failed()
                error.values.forEach{ value in
                    let data = value as! [String:AnyObject]
                    failController.reasonFail = data["message"] as! String
                }

                PayME.currentVC!.presentPanModal(failController)
            })
        } else if(data[active].type == "Napas") {
            self.showSpinner(onView: PayME.currentVC!.view)
            PayME.postTransferNapas(method: data[active], onSuccess: { response in
                let webViewController = WebViewController(nibName: "WebView", bundle: nil)
                webViewController.form = response["form"] as! String
                webViewController.setOnSuccessWebView(onSuccessWebView: { responseFromWebView in
                    webViewController.dismiss(animated: true)
                    PayME.currentVC!.presentPanModal(Success())
                })
                webViewController.setOnFailWebView(onFailWebView: { responseFromWebView in
                    webViewController.dismiss(animated: true)
                    let failController = Failed()
                    failController.reasonFail = responseFromWebView
                    PayME.currentVC!.presentPanModal(failController)
                })
                
                self.dismiss(animated: true) {
                    self.removeSpinner()
                    PayME.currentVC!.presentPanModal(webViewController)
                }
            }, onError: { error in
                self.removeSpinner()
                self.dismiss(animated: true)
                let failController = Failed()
                failController.reasonFail = error[1001] as! String
                PayME.currentVC!.presentPanModal(failController)
            })
        } else if(data[active].type == "PVCBank") {
            self.showSpinner(onView: PayME.currentVC!.view)
            PayME.postTransferPVCB(method: data[active], onSuccess: { response in
                self.removeSpinner()
                self.dismiss(animated: true)
                PayME.currentVC!.presentPanModal(Success())
            }, onError: {error in
                self.removeSpinner()
                print(error)
                if (error[1004] != nil) {
                    self.dismiss(animated: true)
                    let data = error[1004] as! [String:AnyObject]
                    OTP.transferId = data["transferId"] as! Int
                    PayME.currentVC!.presentPanModal(OTP())

                } else {
                    let failController = Failed()
                    self.dismiss(animated: true)
                    error.values.forEach{ value in
                        let data = value as! [String:AnyObject]
                        failController.reasonFail = data["message"] as! String
                    }
                    PayME.currentVC!.presentPanModal(failController)
                }
            })
        }
    }

    
    
    let detailView : UIView = {
        let detailView  = UIView()
        detailView.translatesAutoresizingMaskIntoConstraints = false
        return detailView
    }()
    
    let tableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .red
        tableView.separatorStyle = .none
        
        return tableView
    }()

    let price : UILabel = {
        let price = UILabel()
        price.textColor = .white
        price.backgroundColor = .clear
        price.font = UIFont(name: "Arial", size: 32)
        price.translatesAutoresizingMaskIntoConstraints = false
        return price
    }()
    
    let memoLabel : UILabel = {
        let memoLabel = UILabel()
        memoLabel.textColor = .white
        memoLabel.backgroundColor = .clear
        memoLabel.font = UIFont(name: "Arial", size: 16)
        memoLabel.translatesAutoresizingMaskIntoConstraints = false
        memoLabel.textAlignment = .right
        return memoLabel
    }()
    
    let methodTitle : UILabel = {
        let methodTitle = UILabel()
        methodTitle.textColor = UIColor(114,129,144)
        methodTitle.backgroundColor = .clear
        methodTitle.font = UIFont(name: "Arial", size: 16)
        methodTitle.translatesAutoresizingMaskIntoConstraints = false
        return methodTitle
    }()
    
    let contentLabel : UILabel = {
        let contentLabel = UILabel()
        contentLabel.textColor = .white
        contentLabel.backgroundColor = .clear
        contentLabel.font = UIFont(name: "Arial", size: 16)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        return contentLabel
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

    
    let button : UIButton = {
        let button = UIButton()
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let temp = data
        for i in 0..<data.count {
            if (i == indexPath.row) {
                temp[i].active = true
            } else {
                temp[i].active = false
            }
        }
        self.active = indexPath.row
        self.data = temp

        tableView.reloadData()
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
extension Methods{
    func numberOfSectionsInTableView(_tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? Method
            else { return UITableViewCell() }
        cell.configure(with: data[indexPath.row])

        return cell
    }
}


