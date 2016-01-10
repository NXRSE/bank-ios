//
//  TCPClient.swift
//  Bank
//
//  Created by Kyle Redelinghuys on 2015/12/04.
//  Copyright © 2015 Kyle Redelinghuys. All rights reserved.
//

import Foundation

struct NewAccount {
    var firstName: String
    var familyName: String
    var dateOfBirth: String
    var idNumber: String
    var email: String
    var contactNumber: String
    var address: String
    var postalCode: String
}

struct UserAccount {
    var userID: String
    var userPassword: String
}

final class TCPClient {
    
    class func doLogin (account: UserAccount) -> String {
        let command = "0~appauth~2~"+account.userID+"~"+account.userPassword
        var response = doTCPCall(command)
        
        // @TODO Make this less hacky
        if response == "0~Authentication credentials invalid" {
            response = ""
        }
        
        return response

    }

    class func doCreateAccount (account: NewAccount) -> String {
        
        // @TODO Make struct full - matching backend - and this can be collpased programmatically
        let createAccountString = "0~acmt~1~"+account.firstName+"~"+account.familyName+"~"+account.dateOfBirth+"~"+account.idNumber+"~"+account.contactNumber+"~~"+account.email+"~"+account.address+"~~~"+account.postalCode
        
        return doTCPCall(createAccountString)
        
    }
    
    class func doCreateLogin (account: UserAccount) -> String {
        
        let createLoginString = "0~appauth~3~"+account.userID+"~"+account.userPassword
        
        return doTCPCall(createLoginString)
        
    }
    
    class func doCheckToken (token: String) -> String {
        
        let checkTokenString = token+"~appauth~1"
        
        return doTCPCall(checkTokenString)
        
    }
    
    class func doListAccounts (token: String) -> String {
        let listAccountsString = token+"~acmt~1000";
        
        return doTCPCall(listAccountsString)
    }
    
    class func doListAccount (token: String) -> String {
        let listAccountsString = token+"~acmt~1001";
        
        return doTCPCall(listAccountsString)
    }
    
    class func doMakePayment (token: String, senderAccountNumber: String, recipientAccountNumber: String, senderBankNumber: String, recipientBankNumber: String,  paymentAmount: Float) -> String {
        // @TODO Leave bank number out for now as all accounts are on the same bank
        
        // Convert float to string
        let paymentString = paymentAmount.description
        let paymentsString = token+"~pain~1~"+senderAccountNumber+"@~"+recipientAccountNumber+"@~"+paymentString;
        
        return doTCPCall(paymentsString)
    }
    
    class func doMakeDeposit (token: String, paymentAmount: Float, accountNumber: String, bankNumber: String) -> String {
        let listAccountsString = token+"~pain~1000~"+accountNumber+"@~"+paymentAmount.description;
        
        return doTCPCall(listAccountsString)
    }
    
    
    class func doTCPCall (command: String) -> String{
        let s   =   TCPIPSocket()
        let f   =   NSFileHandle(fileDescriptor: s.socketDescriptor)
        
        print(command)
        
        // @TODO: Does not work over TLS
        // http://stackoverflow.com/a/30648011
        
        // Vagrant: 192.168.33.110, port:
        // bank.ksred.me: 109.237.24.211
        s.connect(TCPIPSocketAddress(109, 237, 24, 211), 6600)
        //s.connect(TCPIPSocketAddress(127, 0, 0, 1), 6600)
        //loginString = "0~appauth~2~52d27bde-9418-4a5d-8528-3fb32e1a5d69~TestPassword"
        f.writeData((command as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        let d   =   f.readDataToEndOfFile()
        
        print(NSString(data: d, encoding: NSUTF8StringEncoding)!)
        
        var response = NSString(data: d, encoding: NSUTF8StringEncoding)! as String
        
        // Replace all newlines
        response = response.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        print(response)
        // @TODO: Check token here, in one place
        return response
    }
}