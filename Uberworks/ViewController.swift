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
//    var image = UIImage(named: "like")
    var image = UIImage(named: "gps-marker")

    override func viewDidLoad() {
        super.viewDidLoad()
        triggerAnimation()
        self.view.userInteractionEnabled = false
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
        
        let circleMaskTransform = CAKeyframeAnimation(keyPath: "transform")
        circleMaskTransform.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut),CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut),CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]

        circleMaskTransform.duration = duration * 2
        circleMaskTransform.values = [
            NSValue(CATransform3D: CATransform3DIdentity),
            NSValue(CATransform3D: CATransform3DMakeScale(1.3, 1.3, 1.0)),
            NSValue(CATransform3D: CATransform3DIdentity)
        ]
        circleMaskTransform.keyTimes = [
            0.0,
            0.6,
            1.0
        ]

        
        imageShapeLayer.addAnimation(circleMaskTransform, forKey: circleMaskTransform.keyPath)
        return imageShapeLayer
    }
    
    func triggerAnimation() {
        self.view.layer.addSublayer(self.animatedCircleAtPoint(self.view.center, radius: 20))
        self.view.layer.addSublayer(self.createImageLayers(self.image!))
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
        circle.contents = image?.CGImage
        
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
        
        return circle
    }
    
    func animatedCircleBorderAtPoint(center: CGPoint, radius: CGFloat) -> CAShapeLayer {
        let borderPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: true);
        let expandedCirclePath = UIBezierPath(arcCenter:center, radius:radius+10, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: true);

        let circleBorder = CAShapeLayer()
        circleBorder.path = borderPath.CGPath
        circleBorder.lineCap = kCALineCapRound
        circleBorder.strokeColor = UIColor.whiteColor().CGColor
        circleBorder.fillColor = UIColor.clearColor().CGColor
        circleBorder.lineWidth = 2.0
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
        print(self.view.layer.sublayers)
        self.view.layer.sublayers = nil;
        triggerAnimation()
    }
}