//
//  HomeViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/14.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit
import Charts

class HomeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var panGesture: UIPanGestureRecognizer!

    @IBOutlet var tableView: UITableView!
    
    var titleOfOtherPages = ""
    let titles = ["Instances", "VCPUs", "RAM", "Security group"]
    let label = ["Used", "Unused"]
    var data: [[Double]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    private func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.computeServiceURL
            let token = user.tokenID
            NeCTAREngine.sharedEngine.getLimit(url, token: token).then{ (json) -> Void in
                
                let absolute = json["limits"]["absolute"]
                let usedInstaces = absolute["totalInstancesUsed"].doubleValue
                let unUsedInstances = absolute["maxTotalInstances"].doubleValue - usedInstaces
                self.data.append([usedInstaces, unUsedInstances])
                
                
                let usedCpus = absolute["totalCoresUsed"].doubleValue
                let unUsedCpus = absolute["maxTotalCores"].doubleValue - usedCpus
                self.data.append([usedCpus, unUsedCpus])
                
                let usedRAM = absolute["totalRAMUsed"].doubleValue
                let unUsedRAM = absolute["maxTotalRAMSize"].doubleValue - usedRAM
                self.data.append([usedRAM, unUsedRAM])
                
                let usedSG = absolute["totalSecurityGroupsUsed"].doubleValue
                let unUsedSG = absolute["maxSecurityGroups"].doubleValue - usedSG
                self.data.append([usedSG, unUsedSG])
                
//                print(self.data)
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if data.count > 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("OverviewCell") as! OverViewCell
            cell.setChart(label, values: data[indexPath.row] )
            cell.title.text = titles[indexPath.row]
        
            return cell
        }
        return UITableViewCell()

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showOtherPages" {
            if let a = segue.destinationViewController as? OtherPageViewController {
                a.PageTitle = titleOfOtherPages
            }
        }
    }
}
