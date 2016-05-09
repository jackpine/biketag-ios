//
//  DevicesService.swift
//  BikeTag
//
//  Created by Michael Kirk on 4/9/16.
//  Copyright © 2016 Jackpine. All rights reserved.
//

import Alamofire

class DevicesService: ApiService {

  func postNewDevice(deviceNotificationToken: String, successCallback: ()->(), errorCallback: (NSError)->()) {

    let deviceParameters = [ "notification_token": deviceNotificationToken ]
    let parameters = [ "device": deviceParameters ]

    let postDeviceRequest = APIRequest.build(Method.POST, path: "devices.json", parameters: parameters)

    let handleResponseAttributes = { (responseData: AnyObject) -> () in
      successCallback()
    }

    self.request(postDeviceRequest, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback)
  }

}