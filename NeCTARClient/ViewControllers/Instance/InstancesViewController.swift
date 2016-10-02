//
//  InstancesViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/16.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit
import MBProgressHUD

class InstancesViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.computeServiceURL
            let token = user.tokenID
            NeCTAREngine.sharedEngine.listInstances(url, token: token).then{ (json) -> Void in
                let servers = json["servers"].arrayValue
                InstanceService.sharedService.clear();
                for server in servers {
                    let instance = Instance(json: server)
                    InstanceService.sharedService.instances.append(instance!)
                    self.tableview.reloadData()
                    print(json)
                    self.refreshControl.endRefreshing()
                    MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                }
                }.error{(err) -> Void in
                    var errorMessage:String!
                    switch err {
                    case NeCTAREngineError.CommonError(let msg):
                        errorMessage = msg
                    default:
                        errorMessage = "Fail to get all instances."
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(InstancesViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableview.addSubview(refreshControl)
        commonInit()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(statusChanged), name: "StatusChanged", object: nil)
    }
    
    func statusChanged() {
        self.tableview.reloadData()
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        commonInit()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return InstanceService.sharedService.instances.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if InstanceService.sharedService.instances.count != 0 {
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
            detailVC.instance = InstanceService.sharedService.instances[(path?.row)!]
            detailVC.index = path?.row
            
        }
    }

}
