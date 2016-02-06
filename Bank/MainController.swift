//
//  MainController.swift
//  Bank
//
//  Created by Kyle Redelinghuys on 2016/02/06.
//  Copyright © 2016 Kyle Redelinghuys. All rights reserved.
//

import Foundation

import UIKit

class MainController: UIViewController {
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loginButton.backgroundColor = UIColor.clearColor()
        //loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}