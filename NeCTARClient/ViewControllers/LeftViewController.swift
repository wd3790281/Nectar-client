//
//  LeftViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/14.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit
import SnapKit

class LeftViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tenantName: UILabel!
    @IBOutlet var userName: UILabel!
    @IBOutlet var tableView: UITableView!
    
    let menu = ["Overview", "Instances", "Volumes", "Images", "Access & Security"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.snp_makeConstraints{ (make) -> Void in
            make.width.equalTo(Common.screenWidth * 0.8 - 30)
        }
        self.tenantName.snp_makeConstraints{(make) -> Void in
            make.width.equalTo(Common.screenWidth * 0.8 - 30)
        }
        self.userName.snp_makeConstraints{(make) -> Void in
            make.width.equalTo(Common.screenWidth * 0.8 - 30)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = menu[indexPath.row]
               return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let viewController = UIApplication.sharedApplication().keyWindow?.rootViewController as! ViewController
        if ( indexPath.row != 0){
            viewController.homeViewController.titleOfOtherPages = menu[indexPath.row]
            viewController.homeViewController.performSegueWithIdentifier("showOtherPages", sender: self)
        }
        viewController.showHome()
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}
