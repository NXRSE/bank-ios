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
    
    @IBOutlet weak var loginOutlet: UIButton!
    @IBOutlet weak var loginOutletButton: UILabel!
    @IBOutlet weak var idNumberField: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func logInButton(sender: AnyObject) {
        
        // Check defaults
        let userID = NSUserDefaults.standardUserDefaults().stringForKey("userID");
        let password = NSUserDefaults.standardUserDefaults().stringForKey("userPassword");
        
        if (password! == "") {
            // @TODO Check to see if this fails
            errorLabel.text = "Please input password"
            return
        }
        
        if (password != nil && userID != nil) {
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
            idNumberField.hidden = false;
            let idNumber = idNumberField.text;
            if (idNumber! == "") {
                errorLabel.text = "Please input ID Number"
                return
            }
            
            // Check if account exists with ID Number
            let idResult = TCPClient.doCheckAccountByID(idNumber!)
            if (idResult != "0~Account does not exist") {
                // Set userid
                NSUserDefaults.standardUserDefaults().setObject(idResult, forKey: "userID")
                // Do login
                let accountDetails = UserAccount(userID: idResult, userPassword: password!)
                
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
                // Go to sign up screen
                // Load view
                let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("SignUpView")
                self.showViewController(vc as! UIViewController, sender: vc)
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //loginOutletButton
        loginOutlet.backgroundColor = UIColor.clearColor()
        //loginOutlet.layer.cornerRadius = 5
        loginOutlet.layer.borderWidth = 1
        loginOutlet.layer.borderColor = UIColor.whiteColor().CGColor
        
        // Swipes
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        leftSwipe.direction = .Left
        view.addGestureRecognizer(leftSwipe)
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("MainController")
            self.showViewController(vc as! UIViewController, sender: vc)
        }
    }
}
