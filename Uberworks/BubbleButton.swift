//
//  BubbleButton.swift
//  Uberworks
//
//  Created by Pablo Alcalde on 16/12/15.
//  Copyright © 2015 Underplot ltd. All rights reserved.
//

import Foundation
import UIKit

protocol BubbleButtonProtocol {
    func didFinishAnimating()
}

class BubbleButton: UIView {
    private let duration = 1.0
    private var circleLayer : CAShapeLayer!
    private var imageLayer : CALayer!
    private var ringLayer : CAShapeLayer!
    private(set) var finishAnimation = false
    internal var delegate : BubbleButtonProtocol?
    
    init(frame: CGRect, imageView: UIImageView?) {
        super.init(frame: frame)
        self.ringLayer = self.ringLayer(CGPointMake(frame.width/2, frame.height/2), radius: frame.width/2)
        self.circleLayer = circleAtPoint(CGPointMake(frame.width/2, frame.height/2), radius: frame.width/2)
        
        if let imageGiven = imageView?.image {
            self.imageLayer = createImageLayers(imageGiven, frame: imageView!.frame)
            self.imageLayer.position = CGPointMake(self.circleLayer.frame.width/2, self.circleLayer.frame.height/2)
            self.circleLayer.addSublayer(self.imageLayer)
        }
        
        self.layer.addSublayer(self.circleLayer)
        self.layer.addSublayer(self.ringLayer)
        self.layer.backgroundColor = UIColor.clearColor().CGColor
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func start() {
        self.finishAnimation = false
        self.circleLayer.removeAllAnimations()
        self.ringLayer.removeAllAnimations()
        self.shrink()
        
        if let presentationLayer = self.ringLayer.presentationLayer() { self.ringLayer.transform = presentationLayer.transform }
        addExpandedAnimationToLayer(self.ringLayer, timesBigger: 1.5)
    }
    
    func stop() {
        self.finishAnimation = true
    }
    
    private func circleAtPoint(center: CGPoint, radius: CGFloat) -> CAShapeLayer {
        let circlePath = UIBezierPath(arcCenter:center, radius:radius, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: true);
        let circle = CAShapeLayer()
        circle.path = circlePath.CGPath
        circle.lineCap = kCALineCapRound
        circle.strokeColor = UIColor.whiteColor().CGColor
        circle.fillColor = UIColor.whiteColor().CGColor
        circle.bounds = self.bounds
        circle.position = center
        return circle
    }
    
    private func createImageLayers(image: UIImage, frame:CGRect) -> CALayer {
        let imgCenterPoint = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
        let imageShapeLayer = CALayer()
        imageShapeLayer.bounds = frame
        imageShapeLayer.position = imgCenterPoint
        imageShapeLayer.backgroundColor = UIColor.blackColor().CGColor
        imageShapeLayer.mask = CALayer()
        imageShapeLayer.mask!.contents = image.CGImage
        imageShapeLayer.mask!.bounds = frame
        imageShapeLayer.mask!.position = imgCenterPoint
        self.layer.addSublayer(imageShapeLayer)
        return imageShapeLayer
    }
    
    private func transformAnimation(timesBigger: CGFloat) -> CABasicAnimation {
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
    
    private func ringLayer(center: CGPoint, radius: CGFloat) -> CAShapeLayer {
        let borderPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: true);
        
        let circleBorder = CAShapeLayer()
        circleBorder.path = borderPath.CGPath
        circleBorder.lineCap = kCALineCapRound
        circleBorder.strokeColor = UIColor.whiteColor().CGColor
        circleBorder.fillColor = UIColor.clearColor().CGColor
        circleBorder.lineWidth = 1.0
        circleBorder.opacity = 0
        circleBorder.bounds = self.bounds
        circleBorder.position = center
        
        return circleBorder
    }
    
    private func addExpandedAnimationToLayer(layer: CAShapeLayer, timesBigger: CGFloat) {
        let animation = self.transformAnimation(timesBigger)
        layer.addAnimation(animation, forKey: animation.keyPath)
        
        let animateOpacity = CABasicAnimation(keyPath: "opacity")
        animateOpacity.fromValue = 1.0
        animateOpacity.toValue = 0.0
        animateOpacity.duration = duration
        animateOpacity.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animateOpacity.fillMode = kCAFillModeForwards
        
        layer.addAnimation(animateOpacity, forKey: animateOpacity.keyPath)
    }
    
    private func expand() {
        self.circleLayer.addAnimation(self.transformAnimation(1.0), forKey: "expand")
    }
    
    private func shrink() {
        self.circleLayer.addAnimation(self.transformAnimation(0.7), forKey: "shrink")
        self.ringLayer.opacity = 0
    }
    
    private func finish() {
        let expandAnim = self.transformAnimation(1.0)
        expandAnim.duration = duration/2
        self.circleLayer.addAnimation(expandAnim, forKey: "finish")
        let animateOpacity = CABasicAnimation(keyPath: "opacity")
        animateOpacity.fromValue = 0.0
        animateOpacity.toValue = 1.0
        animateOpacity.duration = duration/2
        animateOpacity.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animateOpacity.fillMode = kCAFillModeForwards
        animateOpacity.repeatCount = 1
        self.ringLayer.opacity = 1
        self.ringLayer.addAnimation(animateOpacity, forKey: "ringLayer")
        self.addExpandedAnimationToLayer(self.ringLayer, timesBigger: 1.3)
    }
    
   private func finishWithSpring() {
        let expandAnim = CASpringAnimation(keyPath: "transform")
        expandAnim.toValue = NSValue(CATransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0))
        expandAnim.duration = duration
        expandAnim.fillMode = kCAFillModeForwards
        expandAnim.removedOnCompletion = false
        expandAnim.repeatCount = 1
        expandAnim.mass = 1.0
        expandAnim.damping = 10.0
        expandAnim.delegate = self
        self.circleLayer.addAnimation(expandAnim, forKey: "finish")
        
        
        let animateOpacity = CABasicAnimation(keyPath: "opacity")
        animateOpacity.fromValue = 0.0
        animateOpacity.toValue = 1.0
        animateOpacity.duration = duration/2
        animateOpacity.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animateOpacity.fillMode = kCAFillModeForwards
        animateOpacity.repeatCount = 1
        self.ringLayer.opacity = 1;
        self.ringLayer.addAnimation(animateOpacity, forKey: "ringLayer")
    
        self.ringLayer.addAnimation(self.transformAnimation(1.4), forKey: "transform")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if let circlePresentationLayer = self.circleLayer.presentationLayer() { self.circleLayer.transform = circlePresentationLayer.transform }
        
        if anim == self.circleLayer.animationForKey("shrink") {
            self.circleLayer.removeAnimationForKey("shrink")
            if (self.finishAnimation) {
                self.finishWithSpring()
            } else {
                self.expand()
            }
        } else if anim == self.circleLayer.animationForKey("expand")  {
            self.circleLayer.removeAnimationForKey("expand")
            self.shrink()
            self.ringLayer.transform = CATransform3DIdentity
            addExpandedAnimationToLayer(self.ringLayer, timesBigger: 1.3)
        } else if anim == self.circleLayer.animationForKey("finish")  {
            self.circleLayer.removeAnimationForKey("finish")
            self.delegate?.didFinishAnimating()
        }
    }
}