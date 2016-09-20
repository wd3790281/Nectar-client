//
//  InstanceService.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/21.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import Foundation

class Instances {
    static let sharedService = Instances()
    
    var instances: [Instance] = []
    
    func clear() {
        self.instances = []
    }
}