//
//  TLSTest.swift
//  Bank
//
//  Created by Kyle Redelinghuys on 2016/01/28.
//  Copyright © 2016 Kyle Redelinghuys. All rights reserved.
//

import Foundation
import Security

/*

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

//@TODO Try implementing https://developer.apple.com/library/ios/documentation/Security/Reference/secureTransportRef/
 func doTLSCall (command: String) -> String {
    var socketfd = Darwin.socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
    
    var addr = Darwin.sockaddr_in(sin_len: __uint8_t(sizeof(sockaddr_in)), sin_family: sa_family_t(AF_INET), sin_port: CFSwapInt16(4333), sin_addr: in_addr(s_addr: inet_addr("127.0.0.1")), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    var sock_addr = Darwin.sockaddr(sa_len: 0, sa_family: 0, sa_data: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    Darwin.memcpy(&sock_addr, &addr, Int(sizeof(sockaddr_in)))
    
    var err = Darwin.connect(socketfd, &sock_addr, socklen_t(sizeof(sockaddr_in)))
 
    if let sslContext = SSLCreateContext(kCFAllocatorDefault, SSLProtocolSide.ClientSide, SSLConnectionType.StreamType) {
        SSLSetIOFuncs(sslContext, sslReadCallback, sslWriteCallback)
        SSLSetConnection(sslContext, &socketfd)
        SSLSetSessionOption(sslContext, SSLSessionOption.BreakOnClientAuth, true)
        SSLHandshake(sslContext)
    }
    
    return "ok";
}

*/