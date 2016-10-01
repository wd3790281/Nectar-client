//
//  ActionsViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/9/21.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit
import IBAnimatable

class ActionsViewController: BaseViewController {

    var backImage: UIImage?
    var instance: Instance?
    var instanceIndex: Int?
    var upIndex = 0
    var downIndex = 0
    
    var buttons: [UIButton] = []
    var timer: NSTimer = NSTimer()
    var closeImageView = UIImageView()

    override func loadView() {
        super.loadView()
        
        let view = UIView(frame: UIScreen.mainScreen().bounds)
        let imageView = UIImageView(image: self.backImage)
        
        let blurView = UIView(frame: UIScreen.mainScreen().bounds)
        
        blurView.backgroundColor = UIColor(white: 0.9, alpha: 0.8)
        imageView.addSubview(blurView)
        view.addSubview(imageView)
        print("blurview")
        print(blurView.frame.height)
        print("actionview")
        print(view.frame.height)
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.setMenu()
        
        self.setCloseImage()
        
        timer = NSTimer.scheduledTimerWithTimeInterval (0.1, target: self, selector: #selector(self.popupBtn), userInfo: nil, repeats: true)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.touch(_:)))
        
        self.view.addGestureRecognizer(gesture)
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animateWithDuration(0.6, animations:{ () -> Void in
            self.closeImageView.transform = CGAffineTransformRotate(self.closeImageView.transform,CGFloat(M_PI))
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func popupBtn() {
        if (upIndex == self.buttons.count) {
            self.timer.invalidate()
            upIndex = 0
            return
        }
        let btn = self.buttons[upIndex];
        self.popOutOneBtn(btn)
        upIndex += 1
    }
    
    func popOutOneBtn(button: UIButton) {
        
        UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            button.transform = CGAffineTransformIdentity
            }, completion: { (finished) -> Void in
                self.downIndex = self.buttons.count - 1
        })
    }
    
    func setMenu() {
        let columns = 3
        var col = 0
        var row = 0
        
        let width:CGFloat = 100
        let height:CGFloat = 80
        
        let margin = (UIScreen.mainScreen().bounds.size.width - CGFloat(columns) * width) / (CGFloat(columns) + 1)
        
        var titles: [String] = []
        
        switch (instance?.status)! {
            
        case "SUSPENDED":
            titles = ["Resume", "Create Snapshot", "Delete"]
            
        case "PAUSED":
            titles = ["Unpause","Create Snapshot", "Delete"]
            
        case "SHUTOFF":
            titles = ["Start", "HardRebbot", "SoftReboot", "Create Snapshot", "Delete"]
            
        default:
            titles = ["Pause", "Suspend", "Stop", "HardRebbot", "SoftReboot", "Create Snapshot", "Delete"]
        }
       
        
        
        var originY:CGFloat = 300
        
        switch UIScreen.mainScreen().applicationFrame.height {
        case 480:
            originY = 113
        case 568:
            originY = 200
        case 736:
            originY = 369
        default:
            originY = 300
        }
        
        for i in 0 ..< titles.count {
            
            let btn =  SelfDefineButton()
            
            btn.imageView?.contentMode = UIViewContentMode.Center
            btn.titleLabel?.textAlignment = NSTextAlignment.Center
            btn.setTitleColor(UIColor.blackColor(), forState:UIControlState.Normal)
            btn.titleLabel?.font = UIFont.systemFontOfSize(12)
            
            let image = UIImage(named: "button")
            btn.setImage(image, forState: UIControlState.Normal)
            
            let disableImage = UIImage(named: "disableButton")
            btn.setImage(disableImage, forState: UIControlState.Disabled)
            
            btn.setTitle(titles[i], forState: UIControlState.Normal)
                
            col = i % columns
            row = i / columns
            
            if(i == 7) {
                col = 2
            }
            
            let x = margin + CGFloat(col) * (margin + width)
            let y = CGFloat(row) * (margin + height) + originY
            
            btn.frame = CGRectMake(x, y, width, height)
            btn.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height)
            
            btn.addTarget(self, action: #selector(self.btnOnTouch(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            buttons.append(btn)
            
            self.view.addSubview(btn)
        }
        
        
    }
    
    func btnOnTouch (btn: UIButton) {
        UIView.animateWithDuration(0.5, animations:{ () -> Void in
            btn.transform = CGAffineTransformMakeScale(2.0, 2.0)
            btn.alpha = 0
        })
        if let user = UserService.sharedService.user{
            switch btn.currentTitle! {
            case "Pause":
                
                    NeCTAREngine.sharedEngine.instanceAction((self.instance?.id)!, url: user.computeServiceURL, action: "pause", token: user.tokenID).then { (json)
                        -> Void in
                            print(json)
                            self.instance?.status = "PAUSED"
                            self.changeInstanceStatus()
                        }.always{
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }.error { (err) -> Void in
                            print("error")
                            print(err)
                    }
            case "Unpause":
                    NeCTAREngine.sharedEngine.instanceAction((self.instance?.id)!, url: user.computeServiceURL, action: "unpause", token: user.tokenID).then { (json)
                        -> Void in
                            print(json)
                            self.instance?.status = "ACTIVE"
                            self.changeInstanceStatus()
                        }.always{
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }.error { (err) -> Void in
                            print("error")
                            print(err)
                    }

            case "Suspend":
                
                    NeCTAREngine.sharedEngine.instanceAction((self.instance?.id)!, url: user.computeServiceURL, action: "suspend", token: user.tokenID).then { (json)
                        -> Void in
                            print(json)
                            self.instance?.status = "SUSPENDED"
                            self.changeInstanceStatus()
                        }.always{
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }.error { (err) -> Void in
                            print("error")
                            print(err)
                    }
            case "Resume":
                    NeCTAREngine.sharedEngine.instanceAction((self.instance?.id)!, url: user.computeServiceURL, action: "resume", token: user.tokenID).then { (json)
                        -> Void in
                            print(json)
                            self.instance?.status = "ACTIVE"
                            self.changeInstanceStatus()
                        }.always{
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }.error { (err) -> Void in
                            print("error")
                            print(err)
                    }
                
            case "Stop":
                
                    NeCTAREngine.sharedEngine.instanceAction((self.instance?.id)!, url: user.computeServiceURL, action: "stop", token: user.tokenID).then { (json)
                        -> Void in
                            print(json)
                            self.instance?.status = "SHOTOFF"
                            self.changeInstanceStatus()
                        }.always{
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }.error { (err) -> Void in
                            print("error")
                            print(err)
                    }
            case "Start":
                    NeCTAREngine.sharedEngine.instanceAction((self.instance?.id)!, url: user.computeServiceURL, action: "start", token: user.tokenID).then { (json)
                        -> Void in
                            print(json)
                            self.instance?.status = "ACTIVE"
                            self.changeInstanceStatus()
                        }.always{
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }.error { (err) -> Void in
                            print("error")
                            print(err)
                    }
                

            case "HardReboot":
                NeCTAREngine.sharedEngine.rebootInstance((self.instance?.id)!, method: "HARD", url: user.computeServiceURL, token: user.tokenID).then{ (json) -> Void in
                    print (json)
                    self.instance?.status = "ACTIVE"
                    self.changeInstanceStatus()
                    }.always{
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }.error{ (err) -> Void in
                        print (err)
                }

            case "SoftReboot":
                NeCTAREngine.sharedEngine.rebootInstance((self.instance?.id)!, method: "SOFT", url: user.computeServiceURL, token: user.tokenID).then { (json) -> Void in
                    print (json)
                    self.instance?.status = "ACTIVE"
                    self.changeInstanceStatus()
                    
                    }.always{
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }.error{ (err) -> Void in
                        print (err)
                }

            case "Create Snapshot":
                createSnapshot()
                self.dismissViewControllerAnimated(false, completion: nil)
            default:
                NeCTAREngine.sharedEngine.instanceAction((self.instance?.id)!, url: user.computeServiceURL, action: "Delete", token: user.tokenID).then {
                    (json) -> Void in
                    print (json)
                    }.always{
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }.error{ (err) -> Void in
                        print("error")
                        print (err)
                }
            }
            
        }
    }
    
    func createSnapshot () {
        
        let alertController = UIAlertController(title: "Create image snapshot", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Name for snapshot"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let okAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction!) -> Void in
            let nameField = (alertController.textFields?.first)! as UITextField
            let name = nameField.text
            if let user = UserService.sharedService.user{
                NeCTAREngine.sharedEngine.createSnapshot((self.instance?.id)!, url:user.computeServiceURL , snapshotName: name!, token: user.tokenID).then{
                    (json) -> Void in
                    
                    }.error {
                        (err) -> Void in
                        var errorMessage:String!
                        switch err {
                        case NeCTAREngineError.CommonError(let msg):
                            errorMessage = msg
                        default:
                            errorMessage = "Fail to create the snapshot."
                        }
                        PromptErrorMessage(errorMessage, viewController: self)
                }
            }
        })
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func changeInstanceStatus() {
        InstanceService.sharedService.instances[instanceIndex!].status = self.instance!.status
    }
    
    func setCloseImage () {
        
        let img = UIImage(named: "cross")
        
        closeImageView = UIImageView(image: img)
        
        closeImageView.frame = CGRectMake(self.view.center.x-15, self.view.frame.size.height-45, 30, 30);
        
        self.view.addSubview(closeImageView)
        
    }

    func returnUpVC() {
        if (downIndex == -1) {
            self.timer.invalidate()
            
            return
        }
        let btn = self.buttons[downIndex]
        
        self.setDownOneBtn(btn)
        self.downIndex -= 1
    }
    
    func setDownOneBtn(button: UIButton) {
        
        UIView.animateWithDuration(0.6, animations: { () -> Void in
            button.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height)
            }, completion: { (finished) -> Void in
                self.dismissViewControllerAnimated(false, completion: nil)
        })
    }
    
    func touch(gesture: UIGestureRecognizer) {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target:self, selector:#selector(returnUpVC), userInfo:nil, repeats:true)
        
        UIView.animateWithDuration(0.3, animations:{ () -> Void in
            self.closeImageView.transform = CGAffineTransformRotate(self.closeImageView.transform, CGFloat(-M_PI_2*1.5))
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}