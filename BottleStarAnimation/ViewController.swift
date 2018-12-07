//
//  ViewController.swift
//  BottleStarAnimation
//
//  Created by 李骏 on 2018/12/7.
//  Copyright © 2018 李骏. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController,UICollisionBehaviorDelegate {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var bottleIV: UIImageView!
    let starNum = 20
    var animator:UIDynamicAnimator?
    lazy var motionManager = CMMotionManager()
    var timer:Timer?
    var dynamicItems = [UIView]()
    var gravity = UIGravityBehavior()
    let starAry = ["star1","star2","star3","star4","star5","star6","star7","star8"]
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startAnimation(self.startButton)
    }

    func stopAnimation() {
        timer?.invalidate()
        self.animator?.removeAllBehaviors()
        for item in dynamicItems {
            item.removeFromSuperview()
        }
        dynamicItems.removeAll()
        motionManager.stopDeviceMotionUpdates()
    }
    func createAnimation() {
        self.startButton.isHidden = true
        guard dynamicItems.count < starNum else {
            self.startButton.isHidden = false
            timer?.invalidate()
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, err) in
                let rotation = atan2(motion!.gravity.x, motion!.gravity.y) - (Double.pi/2)
                guard abs(rotation) > 0.7 else{return}
                self.gravity.setAngle(CGFloat(rotation), magnitude: 0.1)
            }
            return
        }
        dynamicItems.append(createStar())
        animator = UIDynamicAnimator(referenceView: self.bottleIV)
        gravity = UIGravityBehavior(items: dynamicItems)
        gravity.magnitude = 0.8
        
        let collisionTop = UICollisionBehavior(items: dynamicItems)
        let collisionLeft = UICollisionBehavior(items: dynamicItems)
        let collisionRight = UICollisionBehavior(items: dynamicItems)
        let collisionBottom = UICollisionBehavior(items: dynamicItems)
        
        let pLeftTop = CGPoint(x: 9, y: 0)
        let pRightTop = CGPoint(x: 180, y: 0)
        
        let pLeftBottom = CGPoint(x: 39, y: 280)
        let pRightBottom = CGPoint(x: 150, y: 280)
        
        collisionTop.addBoundary(withIdentifier: "boundaryTop" as NSCopying, from: pLeftTop, to: pRightTop)
        collisionLeft.addBoundary(withIdentifier: "boundaryLeft" as NSCopying, from: pLeftTop, to: pLeftBottom)
        collisionRight.addBoundary(withIdentifier: "boundaryRight" as NSCopying, from: pRightBottom, to: pRightTop)
        collisionBottom.addBoundary(withIdentifier: "boundaryBottom" as NSCopying, from: pLeftBottom, to: pRightBottom)
        
        let behavior = UIDynamicItemBehavior(items: dynamicItems)
        behavior.elasticity = 0.4
        
        animator?.addBehavior(gravity)
        animator?.addBehavior(collisionTop)
        animator?.addBehavior(collisionLeft)
        animator?.addBehavior(collisionRight)
        animator?.addBehavior(collisionBottom)
        animator?.addBehavior(behavior)
        
    }
    @IBAction func startAnimation(_ sender: Any) {
        if #available(iOS 10.0, *){
            self.stopAnimation()
            timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true, block: { (timer) in
                self.createAnimation()
            })
        }else{
            
        }
    }
    func createStar() -> UIView {
        let num:Int = Int(arc4random() % 8)
        let star = Star(image: UIImage(named: self.starAry[num]))
        let x = CGFloat(arc4random_uniform(150) + 9)
        star.frame = CGRect(x: x, y: 0, width: 24, height: 24)
        self.bottleIV.addSubview(star)
        return star
    }
}

class Star: UIImageView {
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType{
        return .ellipse
    }
}
