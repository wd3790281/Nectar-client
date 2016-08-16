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
        
        // 给主视图设置背景
        let imageView = UIImageView(image: UIImage(named: "background"))
        imageView.frame = UIScreen.mainScreen().bounds
        self.view.addSubview(imageView)
        
        // 添加左视图，在背景之上，主视图之下
        leftViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LeftViewController") as! LeftViewController

        leftViewController.view.center = CGPointMake(leftViewController.view.center.x - Common.screenWidth * Proportion, leftViewController.view.center.y)

//        leftViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)
        
        centerOfLeftViewBeginning = leftViewController.view.center
        self.view.addSubview(leftViewController.view)
        
        mainView = UIView(frame: self.view.frame)
        homeNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NavigationController") as! UINavigationController
        homeViewController = homeNavigationController.viewControllers.first as! HomeViewController
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
    
    // 响应 UIPanGestureRecognizer 事件
    func pan(recongnizer: UIPanGestureRecognizer) {
        let x = recongnizer.translationInView(self.view).x
        let trueDistance = distance + x // 实时距离

        
        // 如果 UIPanGestureRecognizer 结束，则激活自动停靠
        if recongnizer.state == UIGestureRecognizerState.Ended {
            
            if trueDistance > Common.screenWidth * (Proportion / 3) {
                showLeft()
            } else {
                showHome()
            }
            
            return
        }
        
        // 到达指定地点则停止动画
        if (trueDistance >= Proportion * Common.screenWidth || trueDistance <= 0){
            return
        }

        // 执行平移动画
        if(recongnizer.view!.frame.origin.x >= 0){
            recongnizer.view!.center = CGPointMake(self.view.center.x + trueDistance, self.view.center.y)

            leftViewController.view.center = CGPointMake(centerOfLeftViewBeginning.x + trueDistance, centerOfLeftViewBeginning.y)

        }
    }
    
    
    // show left view
    func showLeft() {
        self.view.addGestureRecognizer(tapGesture)
        distance = Proportion * Common.screenWidth
        doTheAnimate()
    }
    // show home view
    func showHome() {
        self.view.removeGestureRecognizer(tapGesture)
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

