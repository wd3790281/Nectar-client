//
//  InstanceDetailViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/9/18.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit

class InstanceDetailViewController: BaseViewController {
    var instance: Instance?
    
    @IBOutlet var instanceName: UILabel!
    @IBOutlet var imageName: UILabel!
    @IBOutlet var ipAddress: UILabel!
    @IBOutlet var keyPair: UILabel!
    @IBOutlet var size: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var createTime: UILabel!
    
    @IBOutlet var actions: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContent()
    }
    
    func setContent() {
        
        instanceName.text = instance!.name
        imageName.text = instance!.imageRel
        ipAddress.text = instance!.ip4Address
        keyPair.text = instance!.keyName
        size.text = instance!.flavorRel
        status.text = instance!.status
        createTime.text = instance!.createTime
    }
    
    @IBAction func actionsOnClick(sender: AnyObject) {
    }
}
