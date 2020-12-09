//
//  ViewController.swift
//  One Time Code
//
//  Created by Kyle Lee on 5/25/19.
//  Copyright © 2019 Kilo Loco. All rights reserved.
//

import UIKit

class QRNotFound: UIViewController, PanModalPresentable {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(nameLabel)
        view.addSubview(roleLabel)
        view.addSubview(button)
        view.addSubview(image)
        view.addSubview(closeButton)
        nameLabel.text = "Không tìm thấy"
        roleLabel.text = "QRCode không đúng định dạng hoặc không tồn tại. Vui lòng kiểm tra và quét lại"
        button.setTitle("Đóng", for: .normal)
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
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 20).isActive = true
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
        let image = UIImage(named: "qrCodeNotFound", in: resourceBundle, compatibleWith: nil)
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

