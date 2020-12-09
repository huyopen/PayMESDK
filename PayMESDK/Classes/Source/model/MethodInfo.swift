//
//  UserInfo.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import UIKit



import Foundation

public class MethodInfo : Codable {
    internal var amount : Int? = nil
    internal var bankCode : String? = ""
    internal var cardNumber : String? = ""
    internal var detail : String? = ""
    internal var linkedId : Int? = nil
    internal var swiftCode : String? = ""
    internal var type : String = ""
    internal var active: Bool = false

    public init(amount :Int?, bankCode:String?, cardNumber:String?, detail:String?, linkedId: Int?, swiftCode: String?, type: String, active: Bool){
        self.amount = amount
        self.bankCode = bankCode
        self.cardNumber = cardNumber
        self.detail = detail
        self.linkedId = linkedId
        self.swiftCode = swiftCode
        self.type = type
        self.active = active
    }

    public func setAmount(amount: Int?){
        self.amount = amount
    }
    public func setBankCode(bankCode: String){
        self.bankCode = bankCode
    }
    public func setCardNumber(cardNumber: String){
        self.cardNumber = cardNumber
    }
    public func setDetail(detail: String){
        self.detail = detail
    }
    public func setLinkedId(linkedId: Int?){
        self.linkedId = linkedId!
    }
    public func setSwiftCode(swiftCode: String){
        self.swiftCode = swiftCode
    }
    public func setType(type : String) {
        self.type = type
    }
    public func setActive(active: Bool) {
        self.active = active
    }
    public func getAmount() -> Int?{
        return self.amount
    }
    public func getBankCode() -> String?{
        return self.bankCode
    }
    public func getCardNumber() -> String? {
        return self.cardNumber
    }
    public func getDetail() -> String? {
        return self.detail
    }
    public func getLinkedId() -> Int? {
        return self.linkedId
    }
    public func getSwiftCode() -> String? {
        return self.swiftCode
    }
    public func getType() -> String {
        return self.type
    }
    public func getActive() -> Bool {
        return self.active
    }
    
}

