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


class ViewController: UIViewController, BubbleButtonProtocol {
    var image = UIImage(named: "gps-marker")
    var button : BubbleButton!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(image: self.image)
        imageView.frame = CGRectMake(0, 0, 50, 50)
        self.button = BubbleButton.init(frame: CGRectMake(0, 0, 100, 100), imageView: imageView)
        self.button.center = self.view.center
        self.button.delegate = self
        self.view.addSubview(button)
        self.button.start()
    }
    
    @IBAction func buttonTapped(sender: AnyObject) {
        let button = sender as! UIButton
        if (!self.button.finishAnimation) {
            self.button.stop()
        } else {
            button.setTitle("STOP", forState: UIControlState.Normal)
            self.button.start()
        }
    }
    
    func didFinishAnimating() {
        self.doneButton.setTitle("START", forState: UIControlState.Normal)
        print("animation finished")
    }
}