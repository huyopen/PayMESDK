//
//  UserInfo.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//
import Foundation

public class KYCDocument : Codable {
    internal var id : String? = ""
    internal var name : String = ""
    internal var active: Bool = false

    public init(id: String, name: String, active: Bool){
        self.id = id
        self.name = name
        self.active = active
    }
    
    public func setID(id: String){
        self.id = id
    }
    public func setName(name : String) {
        self.name = name
    }
    public func setActive(active: Bool) {
        self.active = active
    }
    public func getID() -> String? {
        return self.id
    }
    public func getName() -> String {
        return self.name
    }
    public func getActive() -> Bool {
        return self.active
    }
    
}

