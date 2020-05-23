//
//  DevicesService.swift
//  BikeTag
//
//  Created by Michael Kirk on 4/9/16.
//  Copyright © 2016 Jackpine. All rights reserved.
//

import Alamofire

class DevicesService: ApiService {
    func postNewDevice(deviceNotificationToken: String, successCallback: @escaping () -> Void, errorCallback: @escaping (Error) -> Void) {
        let deviceParameters = ["notification_token": deviceNotificationToken]
        let parameters = ["device": deviceParameters]

        let handleResponseAttributes = { (_: [String: Any]) -> Void in
            successCallback()
        }

        request(.post, path: "devices.json", parameters: parameters, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback)
    }
}
