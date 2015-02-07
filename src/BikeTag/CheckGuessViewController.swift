//
//  CheckGuessViewController.swift
//  BikeTag
//
//  Created by Michael Kirk on 2/6/15.
//  Copyright (c) 2015 Jackpine. All rights reserved.
//

import UIKit

class CheckGuessViewController: UIViewController {
  @IBOutlet var progressView: UIProgressView!
  @IBOutlet var fakeResponseActions: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    progressView.progress = 0
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    submitGuessToServer()
  }

  func submitGuessToServer() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
      NSThread.sleepForTimeInterval(0.2)
      dispatch_async(dispatch_get_main_queue(), {
        self.progressView.setProgress(0.1, animated:true)
      })

      NSThread.sleepForTimeInterval(0.2)
      dispatch_async(dispatch_get_main_queue(), {
        self.progressView.setProgress(0.5, animated:true)
      })

      NSThread.sleepForTimeInterval(0.2)
      dispatch_async(dispatch_get_main_queue(), {
        self.progressView.setProgress(1.0, animated:true)
      })

      NSThread.sleepForTimeInterval(0.2)
      dispatch_async(dispatch_get_main_queue(), {
        self.handleGuessResponse()
      })
    })
  }

  func handleGuessResponse() {
    fakeResponseActions.hidden = false
  }
}
