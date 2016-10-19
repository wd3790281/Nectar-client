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
    var otherVC: UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch PageTitle {
        case "Instance":
            otherVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("InstancesViewController") as! InstancesViewController
        case "About":
            otherVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AboutViewController") as! AboutViewController
            
        // the following two buttons are hidden, they are not used in this version
        case "Images":
            otherVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
        case "Access & Security":
            otherVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SecurityViewController") as! SecurityViewController
        default:
            let viewController = UIApplication.sharedApplication().keyWindow?.rootViewController as! ViewController
            viewController.showHome()
        }
        if let otherVC = otherVC {
            self.addChildViewController(otherVC)
            self.view.addSubview(otherVC.view)
            otherVC.didMoveToParentViewController(self)
        }
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(OtherPageViewController.goBack))
        self.view.addGestureRecognizer(gesture)
    }
    
    
    
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
