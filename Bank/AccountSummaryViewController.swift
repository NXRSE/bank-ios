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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //410026b3-aabd-4ea1-9158-a49af6c0e077~acmt~1000
        let token = NSUserDefaults.standardUserDefaults().stringForKey("userToken")!;
        let listAccountsResult = TCPClient.doListAccounts(token);
        //print(listAccountsResult);
        
        // Parse account details
        let listAccountsArr = listAccountsResult.componentsSeparatedByString("~")
        //print(listAccountsArr)
        
        if (listAccountsArr[0] == "1") {
            // Successfull call
            // Split accounts from json list into array
            let jsonListAccountsStr = listAccountsArr[1]
            let data = jsonListAccountsStr.dataUsingEncoding(NSUTF8StringEncoding)
            
            do {
            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers )
            
                print(jsonData)
            } catch _ {
                // Error
            }
                
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}