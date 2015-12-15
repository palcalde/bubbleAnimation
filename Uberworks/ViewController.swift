//
//  ViewController.swift
//  Uberworks
//
//  Created by Marin Todorov on 10/29/15.
//  Copyright © 2015 Underplot ltd. All rights reserved.
//

import UIKit

func delay(seconds seconds: Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime, dispatch_get_main_queue()) {
        completion()
    }
}


class ViewController: UIViewController {
    let duration = 1.0
    let radius : CGFloat = 20.0
    var circleLayer : CAShapeLayer!
    var imageLayer : CALayer!
    var ringLayer : CAShapeLayer!
    var finishAnimation = false
    
    var image = UIImage(named: "gps-marker")

    override func viewDidLoad() {
        super.viewDidLoad()
        triggerAnimation()
    }
    
    
    func triggerAnimation() {
        self.ringLayer = self.ringLayer(self.view.center, radius: self.radius)
        self.circleLayer = self.circleAtPoint(self.view.center, radius: radius)
        self.imageLayer = self.createImageLayers(self.image!)
        self.circleLayer.addSublayer(self.imageLayer)
        self.view.layer.addSublayer(self.circleLayer)
        self.view.layer.addSublayer(self.ringLayer)
        self.shrink()
    }
    
    func circleAtPoint(center: CGPoint, radius: CGFloat) -> CAShapeLayer {
        let circlePath = UIBezierPath(arcCenter:center, radius:radius, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: true);
        let circle = CAShapeLayer()
        circle.path = circlePath.CGPath
        circle.lineCap = kCALineCapRound
        circle.strokeColor = UIColor.whiteColor().CGColor
        circle.fillColor = UIColor.whiteColor().CGColor
        circle.bounds = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        circle.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        return circle
    }
    
    private func createImageLayers(image: UIImage) -> CALayer {
        let imageFrame = CGRectMake(0, 0, 20, 20)
        let imgCenterPoint = CGPointMake(CGRectGetMidX(imageFrame), CGRectGetMidY(imageFrame))
        
        let imageShapeLayer = CALayer()
        imageShapeLayer.bounds = imageFrame
        imageShapeLayer.position = self.view.center
        imageShapeLayer.backgroundColor = UIColor.blackColor().CGColor
        self.view.layer.addSublayer(imageShapeLayer)
        
        imageShapeLayer.mask = CALayer()
        imageShapeLayer.mask!.contents = image.CGImage
        imageShapeLayer.mask!.bounds = imageFrame
        imageShapeLayer.mask!.position = imgCenterPoint
        imageShapeLayer.contentsScale = UIScreen.mainScreen().scale
        
        return imageShapeLayer
    }
    
    func transformAnimation(timesBigger: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.toValue = NSValue(CATransform3D: CATransform3DMakeScale(timesBigger, timesBigger, 1.0))
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeForwards
        animation.autoreverses = false
        animation.removedOnCompletion = false
        animation.repeatCount = 1
        animation.delegate = self
        return animation
    }
    
    func ringLayer(center: CGPoint, radius: CGFloat) -> CAShapeLayer {
        let borderPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: true);

        let circleBorder = CAShapeLayer()
        circleBorder.path = borderPath.CGPath
        circleBorder.lineCap = kCALineCapRound
        circleBorder.strokeColor = UIColor.whiteColor().CGColor
        circleBorder.fillColor = UIColor.clearColor().CGColor
        circleBorder.lineWidth = 1.0
        circleBorder.opacity = 0
        circleBorder.frame = self.view.frame

        return circleBorder
    }
    
    func addExpandedAnimationToLayer(circleBorder: CAShapeLayer, timesBigger: CGFloat) {
        let animation = self.transformAnimation(timesBigger)
        circleBorder.addAnimation(animation, forKey: animation.keyPath)

        let animateOpacity = CABasicAnimation(keyPath: "opacity")
        animateOpacity.fromValue = 1.0
        animateOpacity.toValue = 0.0
        animateOpacity.duration = duration
        animateOpacity.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animateOpacity.fillMode = kCAFillModeForwards
        
        circleBorder.addAnimation(animateOpacity, forKey: animateOpacity.keyPath)
    }
    
    @IBAction func buttonTapped(sender: AnyObject) {
        let button = sender as! UIButton
        if (self.finishAnimation) {
            button.setTitle("STOP", forState: UIControlState.Normal)
            self.finishAnimation = false
            self.shrink()
        } else {
            button.setTitle("START", forState: UIControlState.Normal)
            self.finishAnimation = true
        }
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if let presentationLayer = self.circleLayer.presentationLayer() {
            self.circleLayer.transform = presentationLayer.transform
        }
        if anim == self.circleLayer.animationForKey("shrink") {
            print("shrink finished")
            self.circleLayer.removeAnimationForKey("shrink")
            if (self.finishAnimation) {
                self.finish()
            } else {
                self.expand()
            }
        } else if anim == self.circleLayer.animationForKey("expand")  {
            print("expansion finished")
            self.circleLayer.removeAnimationForKey("expand")
            self.shrink()
        } else if anim == self.circleLayer.animationForKey("finish")  {
            self.circleLayer.removeAnimationForKey("finish")
        }
    }
    
    func expand() {
        self.circleLayer.addAnimation(self.transformAnimation(1.0), forKey: "expand")
    }
    
    func shrink() {
        self.circleLayer.addAnimation(self.transformAnimation(0.7), forKey: "shrink")
        self.ringLayer.opacity = 0
        self.addExpandedAnimationToLayer(self.ringLayer, timesBigger: 1.3)
    }
    
    func finish() {
        self.circleLayer.addAnimation(self.transformAnimation(1.0), forKey: "finish")
        let animateOpacity = CABasicAnimation(keyPath: "opacity")
        animateOpacity.fromValue = 0.0
        animateOpacity.toValue = 1.0
        animateOpacity.duration = duration
        animateOpacity.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animateOpacity.fillMode = kCAFillModeForwards
        animateOpacity.repeatCount = 1
        self.ringLayer.opacity = 1;
        self.ringLayer.addAnimation(animateOpacity, forKey: "ringLayer")
    }
}