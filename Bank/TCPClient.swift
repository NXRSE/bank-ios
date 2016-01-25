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
    
    func sslReadCallback(connection: SSLConnectionRef,
        data: UnsafeMutablePointer<Void>,
        var dataLength: UnsafeMutablePointer<Int>) -> OSStatus {
            
            let socketfd = UnsafePointer<Int32>(connection).memory
            
            let bytesRequested = dataLength.memory
            let bytesRead = read(socketfd, data, UnsafePointer<Int>(dataLength).memory)
            
            if (bytesRead > 0) {
                dataLength = UnsafeMutablePointer<Int>.alloc(1)
                dataLength.initialize(bytesRead)
                if bytesRequested > bytesRead {
                    return Int32(errSSLWouldBlock)
                } else {
                    return noErr
                }
            } else if (bytesRead == 0) {
                dataLength = UnsafeMutablePointer<Int>.alloc(1)
                dataLength.initialize(0)
                return Int32(errSSLClosedGraceful)
            } else {
                dataLength = UnsafeMutablePointer<Int>.alloc(1)
                dataLength.initialize(0)
                switch (errno) {
                case ENOENT: return Int32(errSSLClosedGraceful)
                case EAGAIN: return Int32(errSSLWouldBlock)
                case ECONNRESET: return Int32(errSSLClosedAbort)
                default: return Int32(errSecIO)
                }
            }
    }
    
    func sslWriteCallback(connection: SSLConnectionRef,
        data: UnsafePointer<Void>,
        var dataLength: UnsafeMutablePointer<Int>) -> OSStatus {
            
            let socketfd = UnsafePointer<Int32>(connection).memory
            
            let bytesToWrite = dataLength.memory
            let bytesWritten = write(socketfd, data, UnsafePointer<Int>(dataLength).memory)
            
            if (bytesWritten > 0) {
                dataLength = UnsafeMutablePointer<Int>.alloc(1)
                dataLength.initialize(bytesWritten)
                if (bytesToWrite > bytesWritten) {
                    return Int32(errSSLWouldBlock)
                } else {
                    return noErr
                }
            } else if (bytesWritten == 0) {
                dataLength = UnsafeMutablePointer<Int>.alloc(1)
                dataLength.initialize(0)
                return Int32(errSSLClosedGraceful)
            } else {
                dataLength = UnsafeMutablePointer<Int>.alloc(1)
                dataLength.initialize(0)
                if (EAGAIN == errno) {
                    return Int32(errSSLWouldBlock)
                } else {
                    return Int32(errSecIO)
                }
            }
    }
    
   /*
    class func doTLSCall (command: String) -> String{
        var socketfd = Darwin.socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
        
        var addr = Darwin.sockaddr_in(sin_len: __uint8_t(sizeof(sockaddr_in)), sin_family: sa_family_t(AF_INET), sin_port: CFSwapInt16(8080), sin_addr: in_addr(s_addr: inet_addr("192.168.0.113")), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        var sock_addr = Darwin.sockaddr(sa_len: 0, sa_family: 0, sa_data: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        Darwin.memcpy(&sock_addr, &addr, Int(sizeof(sockaddr_in)))
        
        var err = Darwin.connect(socketfd, &sock_addr, socklen_t(sizeof(sockaddr_in)))
        
        if let umc = SSLCreateContext(kCFAllocatorDefault, kSSLClientSide, kSSLStreamType) {
            var sslContext = umc.takeRetainedValue()
            SSLSetIOFuncs(sslContext, sslReadCallback, sslWriteCallback)
            SSLSetConnection(sslContext, &socketfd)
            SSLSetSessionOption(sslContext, kSSLSessionOptionBreakOnClientAuth, Bool(1))
            SSLHandshake(sslContext)
        }
    }
*/
    
}