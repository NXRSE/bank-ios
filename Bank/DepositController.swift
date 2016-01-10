//
//  DepositController.swift
//  Bank
//
//  Created by Kyle Redelinghuys on 2016/01/10.
//  Copyright © 2016 Kyle Redelinghuys. All rights reserved.
//

import Foundation
import UIKit

class DepositController: UIViewController {
    
    // DEPOSITS
    @IBOutlet weak var DepositAmount: UITextField!
    @IBOutlet weak var DepositError: UILabel!
    
    @IBAction func MakeDeposit(sender: AnyObject) {
        let token = NSUserDefaults.standardUserDefaults().stringForKey("userToken")!
        let userID = NSUserDefaults.standardUserDefaults().stringForKey("userID")!;
        // @TODO: Add restraint > 100
        let depositAmount = DepositAmount.text
        let depositAmountFloat = (depositAmount! as NSString).floatValue
        
        if (depositAmountFloat > 100) {
            DepositError.text = "Error: Max 100"
            DepositError.textColor = UIColor(red: 0.1, green: 0, blue: 0, alpha: 1.0)
            return
        }
        
        // Make deposit
        let deposit = TCPClient.doMakeDeposit(token, paymentAmount: depositAmountFloat, accountNumber: userID, bankNumber: "")
        print(deposit)
        if (deposit == "true") {
            NSUserDefaults.standardUserDefaults().setObject("Deposit successful", forKey: "flashMessage")
        } else {
            NSUserDefaults.standardUserDefaults().setObject("Could not be completed", forKey: "flashMessage")
        }
        // Load view
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("AccountLanding")
        self.showViewController(vc as! UIViewController, sender: vc)
        
    }
}
