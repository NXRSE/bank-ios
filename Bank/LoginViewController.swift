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
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func logInButton(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // Check password
        let password = defaults.stringForKey("userPassword");
        if (password != nil) {
            if passwordText.text == password! {
                let token = NSUserDefaults.standardUserDefaults().stringForKey("userToken")!;
                if (token.characters.count == 0) {
                    let alertController = UIAlertController(title: "Bank", message:
                        "Could not get new token", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return

                }
                
                let tokenTest = TCPClient.doCheckToken(token)
                
                // Test token
                if (tokenTest == "0~Token not valid" || tokenTest == "0~Incorrect token") {
                    
                    // Log in for user and get new token
                    let userID = NSUserDefaults.standardUserDefaults().stringForKey("userID")!;
                    let password = NSUserDefaults.standardUserDefaults().stringForKey("userPassword")!;
                    
                    let accountDetails = UserAccount(userID: userID, userPassword: password)
                    
                    // Log in
                    let token = TCPClient.doLogin(accountDetails)
                    if token.characters.count < 0 {
                        let alertController = UIAlertController(title: "Bank", message:
                            "Could not get new token", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        return
                    }
                    
                    // Set token if not blank
                    NSUserDefaults.standardUserDefaults().setObject(token, forKey: "userToken")
                    
                    // Load view
                    let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("AccountLanding")
                    self.showViewController(vc as! UIViewController, sender: vc)
                } else {
                    // Load view
                    let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("AccountLanding")
                    self.showViewController(vc as! UIViewController, sender: vc)
                }
            } else {
                errorLabel.text = "Password incorrect"
                return
            }
        } else {
            
            // Go to sign up screen
            // Load view
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("SignUpView")
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
