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
    
    class func doLogin (account: UserAccount) -> Int {
        /*
        let command = "0~appauth~2~"+account.userID+"~"+account.userPassword
        var response = doTCPCall(command)
        
        // @TODO Make this less hacky
        if response == "0~Authentication credentials invalid" {
            response = ""
        }
        
        return response
*/
        
        //let checkTokenString = token+"~appauth~1"
        var responseReturn = 0;
        let params = ["User": account.userID, "Password" : account.userPassword]
        print(params)
        do {
            let opt = try HTTP.POST(domain + "/auth/login", parameters: params)
            opt.start { response in
                let resp = Response(JSONDecoder(response.data))
                if (response.error != nil) {
                    responseReturn = 0 // -1
                    return
                }
                responseReturn = 1
            }
        } catch {
            responseReturn = 0
        }
        
        //return doTCPCall(checkTokenString)
        return responseReturn
        
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
    
    class func doCheckToken (token: String) -> Int {
        
        //let checkTokenString = token+"~appauth~1"
        var responseReturn = 0;
        
        do {
            let opt = try HTTP.POST(domain + "/auth", headers: ["X-Auth-Token": token])
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
                if let error = response.error {
                    let errorMsg = resp.error!
                    if errorMsg == "httpApiHandlers: Token invalid" {
                        responseReturn = 0 
                    }
                    return
                }
                //let resp = Response(JSONDecoder(response.data))
                responseReturn = 1
            }
        } catch let error {
            print("got an error creating the request: \(error)")
            responseReturn = 0
        }
        
        //return doTCPCall(checkTokenString)
        return responseReturn
    }
    
    class func doCheckAccountByID (idNumber: String) -> String {
        
        // @TODO Implement on server, return user id token if valid
        let checkString = "appauth~1002~"+idNumber
        
        return doTCPCall(checkString)
        
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
        //s.connect(TCPIPSocketAddress(109, 237, 24, 211), 6600)
        s.connect(TCPIPSocketAddress(127, 0, 0, 1), 3300)
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
    
    
    
    //@TODO Try implementing https://developer.apple.com/library/ios/documentation/Security/Reference/secureTransportRef/
    class func doTLSCall (command: String) -> String{
        var socketfd = Darwin.socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
        
        var addr = Darwin.sockaddr_in(sin_len: __uint8_t(sizeof(sockaddr_in)), sin_family: sa_family_t(AF_INET), sin_port: CFSwapInt16(6600), sin_addr: in_addr(s_addr: inet_addr("127.0.0.1")), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        var sock_addr = Darwin.sockaddr(sa_len: 0, sa_family: 0, sa_data: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        Darwin.memcpy(&sock_addr, &addr, Int(sizeof(sockaddr_in)))
        
        let err = Darwin.connect(socketfd, &sock_addr, socklen_t(sizeof(sockaddr_in)))
        print(err)
        
        if let sslContext = SSLCreateContext(kCFAllocatorDefault, SSLProtocolSide.ClientSide, SSLConnectionType.StreamType) {
            SSLSetIOFuncs(sslContext, sslReadCallback, sslWriteCallback)
            SSLSetConnection(sslContext, &socketfd)
            SSLSetSessionOption(sslContext, SSLSessionOption.BreakOnClientAuth, true)
            SSLHandshake(sslContext)
        }
        
        return "ok";
    }

    
}