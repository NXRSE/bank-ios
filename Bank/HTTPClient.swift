//
//  HTTPClient.swift
//  Bank
//
//  Created by Kyle Redelinghuys on 2016/03/21.
//  Copyright © 2016 Kyle Redelinghuys. All rights reserved.
//

import Foundation
import SwiftHTTP
import JSONJoy

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

struct Response: JSONJoy {
    let status: String?
    let error: String?
    let result: String?
    init(_ decoder: JSONDecoder) {
        status = decoder["status"].string
        error = decoder["error"].string
        result = decoder["result"].string
    }
}

let domain = "https://bank.ksred.me:8443"

final class HTTPClient {
    
    class func doLogin (account: UserAccount) -> String {
        let params = ["User": account.userID, "Password" : account.userPassword]
        return doHTTPCall (params, token: "", route: "/auth/login", method: "POST")
    }
    
    class func doCreateAccount (account: NewAccount) -> String {
        
        //return doTCPCall(createAccountString)
        let params = [
            "AccountHolderGivenName": account.firstName,
            "AccountHolderFamilyName" : account.familyName,
            "AccountHolderDateOfBirth" : account.dateOfBirth,
            "AccountHolderIdentificationNumber" : account.idNumber,
            "AccountHolderContactNumber1" : account.contactNumber,
            "AccountHolderContactNumber2" : "",
            "AccountHolderEmailAddress" : account.email,
            "AccountHolderAddressLine1" : account.address,
            "AccountHolderAddressLine2" : "",
            "AccountHolderAddressLine3" : "",
            "AccountHolderPostalCode" : account.postalCode,
        ]
        return doHTTPCall (params, token: "", route: "/auth/account", method: "POST")
        
    }
    
    class func doCreateLogin (account: UserAccount) -> String {
        
        let params = [
            "User": account.userID,
            "Password" : account.userPassword,
        ]
        return doHTTPCall (params, token: "", route: "/account", method: "POST")
        
    }
    
    class func doCheckToken (token: String) -> String {
        
        let params = ["":""]
        return doHTTPCall (params, token: token, route: "/auth", method: "POST")
        
    }
    
    class func doCheckAccountByID (token: String, idNumber: String) -> String {
        
        let params = ["":""]
        return doHTTPCall (params, token: token, route: "/account/"+idNumber, method: "GET")
        
    }
    
    class func doListAccounts (token: String) -> String {
        
        let params = ["":""]
        return doHTTPCall (params, token: token, route: "/account/all", method: "GET")
        
    }
    
    class func doListAccount (token: String) -> String {
        
        let params = ["":""]
        return doHTTPCall (params, token: token, route: "/account", method: "GET")
        
    }
    
    class func doMakePayment (token: String, senderAccountNumber: String, recipientAccountNumber: String, senderBankNumber: String, recipientBankNumber: String,  paymentAmount: Float) -> String {
        
        // @TODO Leave bank number out for now as all accounts are on the same bank
        // Convert float to string
        let paymentString = paymentAmount.description
        
        let params = [
            "SenderDetails" : senderAccountNumber+"@",
            "RecipientDetails" : recipientAccountNumber+"@",
            "Amount" : paymentString
        ]
        return doHTTPCall (params, token: token, route: "/payment/credit", method: "POST")
        
    }
    
    class func doMakeDeposit (token: String, paymentAmount: Float, accountNumber: String, bankNumber: String) -> String {
        
        // Convert float to string
        let paymentString = paymentAmount.description
        
        let params = [
            "AccountDetails" : accountNumber+"@",
            "Amount" : paymentString
        ]
        return doHTTPCall (params, token: token, route: "/payment/deposit", method: "POST")
        
    }
    
    
    class func doHTTPCall (params: [String:String], token: String, route: String, method: String) -> String{
        var responseReturn = "";
        //let params = ["User": account.userID, "Password" : account.userPassword]
        print(params)
        do {
            var opt = try HTTP.POST(domain + route, parameters: params)
            // Add token if sent
            if token != "" {
                opt = try HTTP.POST(domain + route, headers: ["X-Auth-Token": token])
            }
            // Switch to GET
            if method == "GET" {
                opt = try HTTP.GET(domain + route, parameters: params)
                // Add token if sent
                if token != "" {
                    opt = try HTTP.GET(domain + route, headers: ["X-Auth-Token": token])
                }
            }
            
            // Add token if sent
            if token != "" {
                opt = try HTTP.POST(domain + route, headers: ["X-Auth-Token": token])
             }
            // Self signed certs skip
            var attempted = false
            opt.auth = { challenge in
                if !attempted {
                    attempted = true
                    return NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
                }
                return nil
            }

            opt.start { response in
                let resp = Response(JSONDecoder(response.data))
                if (response.error != nil) {
                    responseReturn = resp.error!
                    return
                }
                responseReturn = resp.error!
            }
        } catch {
            responseReturn = ""
        }
        
        //return doTCPCall(checkTokenString)
        return responseReturn
    }
    
}