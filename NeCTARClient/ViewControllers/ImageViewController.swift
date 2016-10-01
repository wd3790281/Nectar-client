//
//  ImageViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/16.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit

class ImageViewController: BaseViewController {
    
    override func viewDidLoad() {
        if let user = UserService.sharedService.user{
            let url = user.imageServiceURL + "v2/images"
            let token = user.tokenID
            NeCTAREngine.sharedEngine.listImages(url, token: token).then{ (json) -> Void in
                print(json)
                }.error{(err) -> Void in
                    var errorMessage:String!
                    switch err {
                    case NeCTAREngineError.CommonError(let msg):
                        errorMessage = msg
                    default:
                        errorMessage = "Fail to get images"
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }

        }
    }

}
