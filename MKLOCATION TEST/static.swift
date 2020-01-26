//
//  static.swift
//  MKLOCATION TEST
//
//  Created by 張慶宇 on 2019/6/18.
//  Copyright © 2019 Sunbu. All rights reserved.
//

import AdSupport
struct commonValues {
    static let adId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
    static let hostURL = "https://team-taiwan-big-bike.herokuapp.com"
    static let getRoomInfoPath = "/room/info/get"
    static let addRoomPath = "/room/info/setup"
}
