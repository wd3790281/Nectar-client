//
//  InstancesViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/16.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit

class InstancesViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.computeServiceURL
            let token = user.tokenID
            NeCTAREngine.sharedEngine.listInstances(url, token: token).then{ (json) -> Void in
                let servers = json["servers"].arrayValue
                Instances.sharedService.clear();
                for server in servers {
                    let instance = Instance(json: server)
                    Instances.sharedService.instances.append(instance!)
                    self.tableview.reloadData()
                    print(json)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Instances.sharedService.instances.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if Instances.sharedService.instances.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("InstanceDetail") as! InstanceDetailCell
            cell.setContent(indexPath.row)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowInstanceDetail" {
            let cell = sender as! InstanceDetailCell
            let path = self.tableview.indexPathForCell(cell)
            let detailVC = segue.destinationViewController as! InstanceDetailViewController
            detailVC.instance = Instances.sharedService.instances[(path?.row)!]
            
        }
    }

}
