//
//  Method.swift
//  PayMESDK
//
//  Created by HuyOpen on 10/28/20.
//

import UIKit

class Method: UITableViewCell {

   struct Constants {
        static let contentInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
        static let avatarSize = CGSize(width: 36.0, height: 36.0)
    }

    // MARK: - Properties

    var presentable = MethodInfo( amount: 0, bankCode: "", cardNumber: "", detail: "", linkedId: nil, swiftCode: "", type: "", active: false)
    // MARK: - Views

    
    let containerView : UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 15.0
        containerView.layer.borderColor = UIColor(203,203,203).cgColor
        containerView.layer.borderWidth = 0.5
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()

    let bankNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(9,9,9)
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let bankContentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(98,98,98)
        label.backgroundColor = .clear
        label.font = label.font.withSize(12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let walletMethodImage: UIImageView = {
        let bundle = Bundle(for: Method.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "ptBank", in: resourceBundle, compatibleWith: nil)
        var bgImage = UIImageView(image: image)
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()
    
    let checkedImage : UIImageView = {
        let bundle = Bundle(for: Method.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "checked", in: resourceBundle, compatibleWith: nil)
        var bgImage = UIImageView(image: image)
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()
    
    let uncheckImage : UIImageView = {
        let bundle = Bundle(for: Method.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "uncheck", in: resourceBundle, compatibleWith: nil)
        var bgImage = UIImageView(image: image)
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()
    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .white
        isAccessibilityElement = true

        let backgroundView = UIView()
        backgroundView.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.8235294118, blue: 0.8274509804, alpha: 1).withAlphaComponent(0.11)
        selectedBackgroundView = backgroundView
        contentView.addSubview(containerView)
        containerView.addSubview(walletMethodImage)
        containerView.addSubview(bankNameLabel)
        containerView.addSubview(checkedImage)
        containerView.addSubview(bankContentLabel)
        // contentView.addSubview(walletMethodImage)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    func setupConstraints() {
        
        
        containerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        containerView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        
        walletMethodImage.heightAnchor.constraint(equalToConstant: 26).isActive = true
        walletMethodImage.widthAnchor.constraint(equalToConstant: 26).isActive = true
        walletMethodImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        walletMethodImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        checkedImage.heightAnchor.constraint(equalToConstant: 18).isActive = true
        checkedImage.widthAnchor.constraint(equalToConstant: 18).isActive = true
        checkedImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        checkedImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        bankNameLabel.leadingAnchor.constraint(equalTo: walletMethodImage.trailingAnchor, constant: 10).isActive = true
        bankNameLabel.trailingAnchor.constraint(equalTo: bankContentLabel.leadingAnchor, constant: -5).isActive = true
        bankNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        
        bankContentLabel.leadingAnchor.constraint(equalTo: bankNameLabel.trailingAnchor, constant: 5).isActive = true
        bankContentLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        

        
        /*[a, b, c, d].forEach {
            $0.priority = UILayoutPriority(UILayoutPriority.required.rawValue - 1)
            $0.isActive = true
        }
         */
        /*
        let avatarWidthConstriant = avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarSize.width)
        let avatarHeightConstraint = avatarView.heightAnchor.constraint(equalToConstant: Constants.avatarSize.height)

        [avatarWidthConstriant, avatarHeightConstraint].forEach {
            $0.priority = UILayoutPriority(UILayoutPriority.required.rawValue - 1)
            $0.isActive = true
        }
         */
        
    }

    // MARK: - Highlight

    /**
     On cell selection or highlight, iOS makes all vies have a clear background
     the below methods address the issue for the avatar view
     */

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - View Configuration

    func configure(with presentable: MethodInfo) {
        self.presentable = presentable
        
        if (presentable.type == "AppWallet") {
            bankNameLabel.text = "Số dư ví"
            bankContentLabel.text = "(\(PayME.formatMoney(input: presentable.amount!))đ)"
        } else {
            bankNameLabel.text = presentable.bankCode!
            bankContentLabel.text = presentable.cardNumber!
        }
        let bundle = Bundle(for: Method.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let checkStateImage = UIImage(named: "checked", in: resourceBundle, compatibleWith: nil)
        let uncheckStateImage = UIImage(named: "uncheck", in: resourceBundle, compatibleWith: nil)
        if (presentable.active == false)
        {
            checkedImage.image = uncheckStateImage
        } else {
            checkedImage.image = checkStateImage

        }
    }

}

