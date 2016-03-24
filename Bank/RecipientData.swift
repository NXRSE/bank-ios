//
//  RecipientData.swift
//  Bank
//
//  Created by Kyle Redelinghuys on 2016/01/10.
//  Copyright © 2016 Kyle Redelinghuys. All rights reserved.
//

import Foundation


let recipientData = getData();

/**/

func getData() -> [Recipient] {
    
    //410026b3-aabd-4ea1-9158-a49af6c0e077~acmt~1000
    let token = NSUserDefaults.standardUserDefaults().stringForKey("userToken")!;
    let listAccountsResult = HTTPClient.doListAccounts(token);
    //print(listAccountsResult);
    
    
    var recipientData: [Recipient] = []
    
    if (listAccountsResult.error! != "") {
        // Successfull call
        // Split accounts from json list into array
        let jsonListAccountsStr = listAccountsResult.message!
        let data = jsonListAccountsStr.dataUsingEncoding(NSUTF8StringEncoding)
        
        do {
            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers )
            
            //print(jsonData)
            
            let listArray: NSArray = jsonData as! NSArray
            
            var count = 0
            for recipientListItem in listArray {
                print(recipientListItem["AccountHolderName"]!)
                let recipientItem = Recipient(
                    accountNumber:recipientListItem["AccountNumber"]! as! String,
                    bankNumber:recipientListItem["BankNumber"]! as! String,
                    accountHolderName: recipientListItem["AccountHolderName"]! as! String,
                    // These will all be 0 so Int is fine
                    accountBalance: recipientListItem["AccountBalance"]! as! Float64,
                    overdraft: recipientListItem["Overdraft"]! as! Float64,
                    availableBalance: recipientListItem["AvailableBalance"]! as! Float64,
                    timestamp: recipientListItem["Timestamp"]! as! Int)
                
                recipientData.insert(recipientItem, atIndex: count)
                count++
            }
        } catch _ {
            // Error
        }
        
    }
    
    /*
    recipientData = [
        Recipient(accountNumber:"ff3e4a1a-f0f8-4df3-8e95-8ad4da548c97", bankNumber:"97e6320d-b67c-4251-9a8b-0cb16bc1899d", accountHolderName: "Kyle Redelinghuys", accountBalance: 0, overdraft: 0, availableBalance: 0, timestamp: 0),
        Recipient(accountNumber:"7dd25602-b699-406a-836f-e94d651a5ef1", bankNumber:"97e6320d-b67c-4251-9a8b-0cb16bc1899d", accountHolderName: "Monkey D Luffy", accountBalance: 0, overdraft: 0, availableBalance: 0, timestamp: 0),
        Recipient(accountNumber:"f99361d8-5a0f-4c56-9422-8a9f89ce5210", bankNumber:"97e6320d-b67c-4251-9a8b-0cb16bc1899d", accountHolderName: "Roronoa Zoro", accountBalance: 0, overdraft: 0, availableBalance: 0, timestamp: 0),
    ]
    */
    
    return recipientData

}
