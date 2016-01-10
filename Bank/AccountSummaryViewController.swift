//
//  AccountSummaryViewController.swift
//  Bank
//
//  Created by Kyle Redelinghuys on 2015/12/03.
//  Copyright © 2015 Kyle Redelinghuys. All rights reserved.
//

import Foundation
import UIKit

class AccountSummaryViewController: UIViewController {
    
    @IBAction func UpdateBalance(sender: AnyObject) {
        //410026b3-aabd-4ea1-9158-a49af6c0e077~acmt~1000
        let token = NSUserDefaults.standardUserDefaults().stringForKey("userToken")!;
        
        // Get balance
        let account = TCPClient.doListAccount(token)
        print(account)
        
        // @TODO: Convert into helper function
        // Parse account details
        let listAccountArr = account.componentsSeparatedByString("~")
        //print(listAccountsArr)
        
        if (listAccountArr[0] == "1") {
            var recipient = Recipient(accountNumber: "", bankNumber: "", accountHolderName: "", accountBalance: 0,
                overdraft: 0, availableBalance: 0, timestamp: 0)
            // Successfull call
            // Split accounts from json list into array
            let jsonListAccountsStr = listAccountArr[1]
            let data = jsonListAccountsStr.dataUsingEncoding(NSUTF8StringEncoding)
            
            do {
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers )
                
                print(jsonData)
                
                recipient = Recipient(
                    accountNumber:jsonData["AccountNumber"]! as! String,
                    bankNumber:jsonData["BankNumber"]! as! String,
                    accountHolderName: jsonData["AccountHolderName"]! as! String,
                    accountBalance: jsonData["AccountBalance"]! as! Float64,
                    overdraft: jsonData["Overdraft"]! as! Float64,
                    availableBalance: jsonData["AvailableBalance"]! as! Float64,
                    timestamp: jsonData["Timestamp"]! as! Int)
            } catch _ {
                // Error
            }
            
            if (recipient.accountHolderName != "") {
                // Update balance
                AmountLabel.text = recipient.availableBalance.description
            }
        }

    }
    
    @IBOutlet weak var AmountLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let flashMessage = NSUserDefaults.standardUserDefaults().stringForKey("flashMessage")
        if (flashMessage?.characters.count > 0) {
            // Update a label
            let alertController = UIAlertController(title: "Bank", message:
                flashMessage!, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            // Reset flash
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "flashMessage")
        }
        
        //410026b3-aabd-4ea1-9158-a49af6c0e077~acmt~1000
        let token = NSUserDefaults.standardUserDefaults().stringForKey("userToken")!;
        // Get balance
        let account = TCPClient.doListAccount(token)
        print(account)
        
        // @TODO: Convert into helper function
        // Parse account details
        let listAccountArr = account.componentsSeparatedByString("~")
        //print(listAccountsArr)
        
        if (listAccountArr[0] == "1") {
            var recipient = Recipient(accountNumber: "", bankNumber: "", accountHolderName: "", accountBalance: 0,
                overdraft: 0, availableBalance: 0, timestamp: 0)
            // Successfull call
            // Split accounts from json list into array
            let jsonListAccountsStr = listAccountArr[1]
            let data = jsonListAccountsStr.dataUsingEncoding(NSUTF8StringEncoding)
            
            do {
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers )
                
                print(jsonData)
                
                recipient = Recipient(
                    accountNumber:jsonData["AccountNumber"]! as! String,
                    bankNumber:jsonData["BankNumber"]! as! String,
                    accountHolderName: jsonData["AccountHolderName"]! as! String,
                    accountBalance: jsonData["AccountBalance"]! as! Float64,
                    overdraft: jsonData["Overdraft"]! as! Float64,
                    availableBalance: jsonData["AvailableBalance"]! as! Float64,
                    timestamp: jsonData["Timestamp"]! as! Int)
                            } catch _ {
                // Error
            }
            
            if (recipient.accountHolderName != "") {
                // Update balance
                AmountLabel.text = recipient.availableBalance.description
            }
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}