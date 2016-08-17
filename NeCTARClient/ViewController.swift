//
//  ViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/7/27.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var homeViewController: HomeViewController!
    var leftViewController: LeftViewController!
    var homeNavigationController: UINavigationController!
    
    var mainView: UIView!
    var tapGesture: UITapGestureRecognizer!
    
    var distance: CGFloat = 0
    let Proportion: CGFloat = 0.8
    var centerOfLeftViewBeginning: CGPoint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add background image to mainview
        let imageView = UIImageView(image: UIImage(named: "background"))
        imageView.frame = UIScreen.mainScreen().bounds
        self.view.addSubview(imageView)
        
        // add left view controller, above background, under main view
        leftViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LeftViewController") as! LeftViewController

        leftViewController.view.center = CGPointMake(leftViewController.view.center.x - Common.screenWidth * Proportion, leftViewController.view.center.y)

//        leftViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)
        
        centerOfLeftViewBeginning = leftViewController.view.center
        self.view.addSubview(leftViewController.view)
        
        mainView = UIView(frame: self.view.frame)
        homeNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NavigationController") as! UINavigationController
        homeViewController = homeNavigationController.viewControllers.first as! HomeViewController
        homeViewController.navigationItem.leftBarButtonItem?.action = #selector(ViewController.showLeft)
        mainView.addSubview(homeViewController.navigationController!.view)
        mainView.addSubview(homeViewController.view)
        self.view.addSubview(mainView)
        
        // 绑定 UIPanGestureRecognizer
        let panGesture = homeViewController.panGesture
        panGesture.addTarget(self, action: #selector(ViewController.pan(_:)))
        mainView.addGestureRecognizer(panGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.showHome))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func pan(recongnizer: UIPanGestureRecognizer) {
        let x = recongnizer.translationInView(self.view).x
        let trueDistance = distance + x // realtime distance

        
        // if UIPanGestureRecognizer end, move to certain position automatically
        if recongnizer.state == UIGestureRecognizerState.Ended {
            
            if trueDistance > Common.screenWidth * (Proportion / 3) {
                showLeft()
            } else {
                showHome()
            }
            
            return
        }
        
        // when reach to certain point, stop aotumactically

        if (trueDistance >= Proportion * Common.screenWidth || trueDistance <= 0){
            return
        }

        // move animate
        if(recongnizer.view!.frame.origin.x >= 0){
            recongnizer.view!.center = CGPointMake(self.view.center.x + trueDistance, self.view.center.y)

            leftViewController.view.center = CGPointMake(centerOfLeftViewBeginning.x + trueDistance, centerOfLeftViewBeginning.y)

        }
    }
    
    
    // show left view
    func showLeft() {
        self.mainView.addGestureRecognizer(tapGesture)
        distance = Proportion * Common.screenWidth
        doTheAnimate()
    }
    // show home view
    func showHome() {
        self.mainView.removeGestureRecognizer(tapGesture)
        distance = 0
        doTheAnimate()
    }


    func doTheAnimate() {
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.mainView.center = CGPointMake(self.view.center.x + self.distance, self.view.center.y)
            self.leftViewController.view.center = CGPointMake(self.centerOfLeftViewBeginning.x + Common.screenWidth * self.Proportion, self.centerOfLeftViewBeginning.y)
            }, completion: nil)
    }


}

