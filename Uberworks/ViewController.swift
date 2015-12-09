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
    let buttonLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        triggerAnimation()
    }
    
    func triggerAnimation() {
        self.view.layer.addSublayer(self.animatedCircleAtPoint(CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2), radius: 20))
    }
    
    func animatedCircleAtPoint(center: CGPoint, radius: CGFloat) -> CAShapeLayer {
        let circle = CAShapeLayer()
        let circlePath = UIBezierPath(arcCenter:center, radius:radius, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: true);
        let expandedRadius = radius+10
        let expandedCirclePath = UIBezierPath(arcCenter:center, radius:expandedRadius, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: true);
        
        circle.path = circlePath.CGPath
        circle.lineCap = kCALineCapRound
        circle.strokeColor = UIColor.whiteColor().CGColor
        circle.fillColor = UIColor.whiteColor().CGColor
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = circlePath.CGPath
        animation.toValue = expandedCirclePath.CGPath
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeBoth
        animation.autoreverses = true
        animation.removedOnCompletion = true
        animation.delegate = self
        circle.addAnimation(animation, forKey: animation.keyPath)
        
        delay(seconds: duration) { () -> () in
            circle.addSublayer((self.animatedCircleBorderAtPoint(center, radius: expandedRadius)))
        }
        
        buttonLayer.addSublayer(circle)
        return buttonLayer
    }
    
    func animatedCircleBorderAtPoint(center: CGPoint, radius: CGFloat) -> CAShapeLayer {
        let borderPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: true);
        let expandedCirclePath = UIBezierPath(arcCenter:center, radius:radius+10, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: true);

        let circleBorder = CAShapeLayer()
        circleBorder.path = borderPath.CGPath
        circleBorder.lineCap = kCALineCapRound
        circleBorder.strokeColor = UIColor.whiteColor().CGColor
        circleBorder.fillColor = UIColor.clearColor().CGColor
        circleBorder.opacity = 1
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = borderPath.CGPath
        animation.toValue = expandedCirclePath.CGPath
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeForwards
        animation.autoreverses = false
        animation.removedOnCompletion = true
        circleBorder.addAnimation(animation, forKey: animation.keyPath)

        UIView.animateWithDuration(duration, delay: 0, options: [.CurveEaseOut], animations: { () -> Void in
            circleBorder.opacity = 0.0
            }, completion: nil)
        return circleBorder
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        for layer in self.buttonLayer.sublayers! {
            layer.removeFromSuperlayer()
        }
        triggerAnimation()
    }
}