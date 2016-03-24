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
    let error: String!
    let result: String!
    init(_ decoder: JSONDecoder) {
        error = decoder["error"].string
        result = decoder["response"].string
    }
}

struct HTTPResult {
    var message: String!
    var error: String!
}

let domain = "https://bank.ksred.me:8443"

final class HTTPClient {
    
    class func doLogin (account: UserAccount) -> HTTPResult {
        
        let params = ["User": account.userID, "Password" : account.userPassword]
        return doHTTPCall (params, token: "", route: "/auth/login", method: "POST")
        
    }
    
    class func doCreateAccount (account: NewAccount) -> HTTPResult {
        
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
        return doHTTPCall (params, token: "", route: "/account", method: "POST")
        
    }
    
    class func doCreateLogin (account: UserAccount) -> HTTPResult {
        
        let params = [
            "User": account.userID,
            "Password" : account.userPassword,
        ]
        return doHTTPCall (params, token: "", route: "/account", method: "POST")
        
    }
    
    class func doCheckToken (token: String) -> HTTPResult {
        
        let params = ["":""]
        return doHTTPCall (params, token: token, route: "/auth", method: "POST")
        
    }
    
    class func doCheckAccountByID (token: String, idNumber: String) -> HTTPResult {
        
        let params = ["":""]
        return doHTTPCall (params, token: token, route: "/account/"+idNumber, method: "GET")
        
    }
    
    class func doListAccounts (token: String) -> HTTPResult {
        
        let params = ["":""]
        return doHTTPCall (params, token: token, route: "/account/all", method: "GET")
        
    }
    
    class func doListAccount (token: String) -> HTTPResult {
        
        let params = ["":""]
        return doHTTPCall (params, token: token, route: "/account", method: "GET")
        
    }
    
    class func doMakePayment (token: String, senderAccountNumber: String, recipientAccountNumber: String, senderBankNumber: String, recipientBankNumber: String,  paymentAmount: Float) -> HTTPResult {
        
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
    
    class func doMakeDeposit (token: String, paymentAmount: Float, accountNumber: String, bankNumber: String) -> HTTPResult {
        
        // Convert float to string
        let paymentString = paymentAmount.description
        
        let params = [
            "AccountDetails" : accountNumber+"@",
            "Amount" : paymentString
        ]
        return doHTTPCall (params, token: token, route: "/payment/deposit", method: "POST")
        
    }
    
    
    class func doHTTPCall (let params: [String:String], token: String, route: String, method: String) -> HTTPResult{
        var responseReturn = HTTPResult(message : "", error : "Error with HTTP call to "+domain+route);
        //let params = ["User": account.userID, "Password" : account.userPassword]
        
        /*
        The below HTTP call is async and currently causes problems if not run in the right order.
        Right now we are using a hacky "lock" variable to sit and wait while the current HTTP req finishes.
        @TODO: Do this properly, using either non-async calls or proper handling of the async.
        */
        
        var locked = true;
        print("Start HTTP")
        
        do {
            var opt = try HTTP.POST(domain + route, parameters: params)
            // Add token if sent
            if token != "" {
                opt = try HTTP.POST(domain + route, headers: ["X-Auth-Token": token], parameters: params)
            }
            
            // Switch to GET
            if method == "GET" {
                opt = try HTTP.GET(domain + route, parameters: params)
                // Add token if sent
                if token != "" {
                    opt = try HTTP.GET(domain + route, headers: ["X-Auth-Token": token], parameters: params)
                }
            }
            
            // Self signed certs skip
            var attempted = false
            opt.auth = { challenge in
                if !attempted {
                    attempted = true
                    locked = false;
                    return NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
                }
                locked = false;
                return nil
            }

            //opt.start(<#T##completionHandler: ((Response) -> Void)##((Response) -> Void)##(Response) -> Void#>)
            
            opt.start { response in
                let resp = Response(JSONDecoder(response.data))
                if (response.error != nil) {
                    print("Call to: "+domain+route+", error")
                    print(resp)
                    responseReturn.error = resp.error!
                    responseReturn.message = ""
                    locked = false;
                    return
                }
                print("Call to: "+domain+route+", success")
                print(resp)
                responseReturn.message = resp.result!
                responseReturn.error = ""
                locked = false;
            }
            
            /*
            opt.onFinish = { response in
                let resp = Response(JSONDecoder(response.data))
                if (response.error != nil) {
                    print("Call to: "+domain+route+", error")
                    print(resp)
                    responseReturn.error = resp.error!
                    responseReturn.message = ""
                    locked = false;
                    //LoginViewController.TestToken(responseReturn)
                    return
                }
                print("Call to: "+domain+route+", success")
                print(resp)
                responseReturn.message = resp.result!
                responseReturn.error = ""
                //LoginViewController.TestToken(responseReturn)
                locked = false;
                
            }
            */
            
        } catch {
            responseReturn.error = "An error occurred"
            responseReturn.message = ""
            locked = false;
        }
        
        while(locked){wait()}
        
        print(responseReturn)
        print("After func")
        
        return responseReturn
    }
   
    
}


func testfunc(token: String) {
    
}