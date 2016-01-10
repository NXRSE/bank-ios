//
//  Recipient.swift
//  Bank
//
//  Created by Kyle Redelinghuys on 2016/01/10.
//  Copyright © 2016 Kyle Redelinghuys. All rights reserved.
//

import UIKit

struct Recipient {
    var accountNumber: String
    var bankNumber: String
    var accountHolderName: String
    var accountBalance: Float64
    var overdraft: Float64
    var availableBalance: Float64
    var timestamp: Int
    
    init(accountNumber: String, bankNumber: String, accountHolderName: String, accountBalance: Float64,
        overdraft: Float64, availableBalance: Float64, timestamp: Int) {
        self.accountNumber = accountNumber
        self.bankNumber = bankNumber
        self.accountHolderName = accountHolderName
        self.accountBalance = accountBalance
        self.overdraft = overdraft
        self.availableBalance = availableBalance
        self.timestamp = timestamp
    }
}
