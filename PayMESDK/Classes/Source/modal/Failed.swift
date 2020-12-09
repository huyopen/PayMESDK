//
//  File.swift
//  PayMESDK
//
//  Created by HuyOpen on 11/6/20.
//

import UIKit

class Failed: UIViewController, PanModalPresentable {
    var reasonFail = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(nameLabel)
        view.addSubview(roleLabel)
        view.addSubview(failLabel)
        view.addSubview(button)
        view.addSubview(image)
        view.addSubview(closeButton)
        view.addSubview(contentLabel)
        view.addSubview(memoLabel)
        nameLabel.text = "Thanh toán thất bại"
        roleLabel.text = PayME.formatMoney(input: PayME.amount)
        failLabel.text = reasonFail
        contentLabel.text = "Nội dung"
        if (PayME.description == "") {
            memoLabel.text = "Không có nội dung"
        } else {
            memoLabel.text = PayME.description
        }
        button.setTitle("HOÀN TẤT", for: .normal)
        roleLabel.lineBreakMode = .byWordWrapping
        roleLabel.numberOfLines = 0
        roleLabel.textAlignment = .center
        setupConstraints()
    }
    
    var panScrollable: UIScrollView? {
        return nil
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
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 19).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        image.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        image.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20.0).isActive = true
        
        roleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4.0).isActive = true
        roleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        roleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        
        failLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 4.0).isActive = true
        failLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        failLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        failLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        contentLabel.topAnchor.constraint(equalTo: failLabel.bottomAnchor, constant: 30).isActive = true
        contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        contentLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        contentLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        memoLabel.topAnchor.constraint(equalTo: failLabel.bottomAnchor, constant: 30).isActive = true
        memoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        memoLabel.leadingAnchor.constraint(equalTo: contentLabel.trailingAnchor, constant: 30).isActive = true
        memoLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        memoLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: button.bottomAnchor, constant: 10).isActive = true
        
        

    }
    
    @objc
    func buttonAction(button:UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    let closeButton : UIButton = {
        let button = UIButton()
        let bundle = Bundle(for: Failed.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "16Px", in: resourceBundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let image: UIImageView = {
        let bundle = Bundle(for: Failed.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "fails", in: resourceBundle, compatibleWith: nil)
        var bgImage = UIImageView(image: image)
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(24,26,65)
        label.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let roleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(25,25,25)
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 38, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let failLabel: UILabel = {
        let failLabel = UILabel()
        failLabel.textColor = UIColor(241,49,45)
        failLabel.backgroundColor = .clear
        failLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        failLabel.lineBreakMode = .byWordWrapping
        failLabel.numberOfLines = 0
        failLabel.textAlignment = .center
        failLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return failLabel
    }()
    
    let button : UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(8,148,31)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        return button
    }()
    
    let contentLabel : UILabel = {
        let contentLabel = UILabel()
        contentLabel.textColor = .black
        contentLabel.backgroundColor = .clear
        contentLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        return contentLabel
    }()
    
    let memoLabel : UILabel = {
        let memoLabel = UILabel()
        memoLabel.textColor = .black
        memoLabel.backgroundColor = .clear
        memoLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        memoLabel.translatesAutoresizingMaskIntoConstraints = false
        memoLabel.textAlignment = .right
        return memoLabel
    }()
    
    override func viewDidLayoutSubviews() {
        button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)
    }
    
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
