//
//  InstanceDetailCell.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/22.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit

class InstanceDetailCell: UITableViewCell {

    @IBOutlet var instanceName: UILabel!
    @IBOutlet var imageName: UILabel!
    @IBOutlet var ipAddress: UILabel!
    @IBOutlet var keypair: UILabel!
    @IBOutlet var size: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var createTime: UILabel!
    
    func setContent(index: Int) {
        let instance = InstanceService.sharedService.instances[index]
        instanceName.text = instance.name
        imageName.text = instance.imageRel
        ipAddress.text = instance.ip4Address
        keypair.text = instance.keyName
        size.text = FlavorService.sharedService.findFlavors(instance.flavorRel)
        status.text = instance.status
        createTime.text = instance.createTime
    }
}
