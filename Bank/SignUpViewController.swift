//
//  SignUpViewController.swift
//  Bank
//
//  Created by Kyle Redelinghuys on 2015/12/03.
//  Copyright © 2015 Kyle Redelinghuys. All rights reserved.
//

import Foundation
import UIKit

class SignUpViewController: UIViewController {

    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var setPasswordButton: UIButton!
    // Sign up
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var postalCodeText: UITextField!
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var contactNumberText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var idNumberText: UITextField!
    @IBOutlet weak var dateOfBirthText: UITextField!
    @IBOutlet weak var familyNameText: UITextField!
    @IBOutlet weak var givenNameText: UITextField!
    
    @IBAction func signUpSubmit(sender: AnyObject) {
        let firstName = givenNameText.text
        let familyName = familyNameText.text
        let dateOfBirth = dateOfBirthText.text
        let idNumber = idNumberText.text
        let email = emailText.text
        let contactNumber = contactNumberText.text
        let address = addressText.text
        let postalCode = postalCodeText.text
        
        // For now we make all fields required
        if firstName?.characters.count == 0 ||
        familyName?.characters.count == 0 ||
        dateOfBirth?.characters.count == 0 ||
        idNumber?.characters.count == 0 ||
        email?.characters.count == 0 ||
        contactNumber?.characters.count == 0 ||
        address?.characters.count == 0 ||
        postalCode?.characters.count == 0 {
            // Not all present
            errorLabel.text = "Not all required fields present"
            return
        }
        
        if dateOfBirth?.characters.count != 8 {
            errorLabel.text = "Date of birth must be: yyymmdd"
            return
        }
        
        // If values there, we submit for account creation
        let accountDetails = NewAccount(firstName: firstName!, familyName: familyName!, dateOfBirth: dateOfBirth!, idNumber: idNumber!, email: email!, contactNumber: contactNumber!, address: address!, postalCode: postalCode!)
        
        let createAccountResult = TCPClient.doCreateAccount(accountDetails)
        print(createAccountResult)
        
        // @TODO Implement more solid response handling, maybe through TCPClient class
        if createAccountResult.characters.count > 0 {
            // Set variables
            NSUserDefaults.standardUserDefaults().setObject(createAccountResult, forKey: "userID")
            // Load account password view
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("PasswordCreate")
            self.showViewController(vc as! UIViewController, sender: vc)
        } else {
            errorLabel.text = "Unable to create account: "+createAccountResult
            return
        }
        
    }
    
    // Password
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var passwordTwoInput: UITextField!
    @IBOutlet weak var passwordOneInput: UITextField!
    
    @IBAction func passwordSubmit(sender: AnyObject) {
        print("Password submitted")
        let passwordOne = passwordOneInput.text
        let passwordTwo = passwordTwoInput.text
        
        if passwordOne?.characters.count == 0 ||
            passwordTwo?.characters.count == 0 {
                passwordErrorLabel.text = "Both fields must be filled in"
                print("Both fields must be filled in")
                return
        }
        
        if passwordOne! != passwordTwo! {
            passwordErrorLabel.text = "Passwords must match"
            print("Passwords must match")
            return
        }
        
        let userID = NSUserDefaults.standardUserDefaults().stringForKey("userID")!
        print("Userid: "+userID)
        let accountDetails = UserAccount(userID: userID, userPassword: passwordOne!)
        
        // Create auth account
        let createAccountResult = TCPClient.doCreateLogin(accountDetails)
        print(createAccountResult)
        
        if createAccountResult != "1~Successfully created account" {
            passwordErrorLabel.text = "Could not create account"
            return
        }
        
        NSUserDefaults.standardUserDefaults().setObject(passwordOne!, forKey: "userPassword")
        
        // Log in
        let token = TCPClient.doLogin(accountDetails)
        if token.characters.count < 0 {
            passwordErrorLabel.text = "Could not log user in"
            return
        }
        
        // Set token if not blank
        NSUserDefaults.standardUserDefaults().setObject(token, forKey: "userToken")
        
        // Load account summary view
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("AccountLanding")
        self.showViewController(vc as! UIViewController, sender: vc)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        // Set styles
        signupButton.backgroundColor = UIColor.clearColor()
        //signupButton.layer.cornerRadius = 5
        signupButton.layer.borderWidth = 1
        signupButton.layer.borderColor = UIColor.whiteColor().CGColor
        //setPasswordButton.backgroundColor = UIColor.clearColor()
        //setPasswordButton.layer.cornerRadius = 5
        //setPasswordButton.layer.borderWidth = 1
        //setPasswordButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        // Swipes
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        leftSwipe.direction = .Left
        view.addGestureRecognizer(leftSwipe)
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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