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
    
    class func doTCPCall (command: String) -> String{
        let s   =   TCPIPSocket()
        let f   =   NSFileHandle(fileDescriptor: s.socketDescriptor)
        
        // @TODO: Does not work over TLS
        // http://stackoverflow.com/a/30648011
        
        // Vagrant: 192.168.33.110, port:
        s.connect(TCPIPSocketAddress(127, 0, 0, 1), 6600)
        //loginString = "0~appauth~2~52d27bde-9418-4a5d-8528-3fb32e1a5d69~TestPassword"
        f.writeData((command as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        let d   =   f.readDataToEndOfFile()
        
        print(NSString(data: d, encoding: NSUTF8StringEncoding)!)
        
        var response = NSString(data: d, encoding: NSUTF8StringEncoding)! as String
        
        // Replace all newlines
        response = response.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        print(response)
        return response
    }
}