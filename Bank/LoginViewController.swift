//
//  LoginViewController.swift
//  Bank
//
//  Created by Kyle Redelinghuys on 2015/12/03.
//  Copyright © 2015 Kyle Redelinghuys. All rights reserved.
//

import Foundation

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBAction func logInButton(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // Check password
        let password = defaults.stringForKey("userPassword")!
        
        if passwordText.text == password {
            // Load view
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("AccountSummary")
            self.showViewController(vc as! UIViewController, sender: vc)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
