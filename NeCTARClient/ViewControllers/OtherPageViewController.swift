//
//  OtherPageViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/16.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit

class OtherPageViewController: BaseViewController {

    @IBOutlet var label: UILabel!
    var PageTitle: String!
    var instanceVC: InstancesViewController!
    var volumeVc: VolumesViewController!
    var securityVC: SecurityViewController!
    var imageVC: ImageViewController!
    var homeVC: HomeViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch PageTitle {
        case "Instances":
            instanceVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("InstancesViewController") as! InstancesViewController
            self.view.addSubview(instanceVC.view)
        case "Volumes":
            volumeVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("VolumesViewController") as! VolumesViewController
            self.view.addSubview(volumeVc.view)
        case "Images":
            imageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
            self.view.addSubview(imageVC.view)
        case "Access & Security":
            securityVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SecurityViewController") as! SecurityViewController
            self.view.addSubview(securityVC.view)
        default:
            let viewController = UIApplication.sharedApplication().keyWindow?.rootViewController as! ViewController
            viewController.showHome()
        }
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(OtherPageViewController.goBack))
        self.view.addGestureRecognizer(gesture)
    }
    
    
    
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
