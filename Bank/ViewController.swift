//
//  ViewController.swift
//  Bank
//
//  Created by Kyle Redelinghuys on 2015/11/26.
//  Copyright © 2015 Kyle Redelinghuys. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBAction func buttonTCP(sender: AnyObject) {
        let s   =   TCPIPSocket()
        let f   =   NSFileHandle(fileDescriptor: s.socketDescriptor)
        
        // @TODO: Does not work over TLS
        // http://stackoverflow.com/a/30648011
        
        // Vagrant: 192.168.33.110, port:
        s.connect(TCPIPSocketAddress(127, 0, 0, 1), 6600)
        //loginString = "0~appauth~2~52d27bde-9418-4a5d-8528-3fb32e1a5d69~TestPassword"
        f.writeData(("0~appauth~2~52d27bde-9418-4a5d-8528-3fb32e1a5d69~TestPassword" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        let d   =   f.readDataToEndOfFile()
        
        print(NSString(data: d, encoding: NSUTF8StringEncoding)!)
        
        // Load view
        // let vc : AnyObject! = self.storyboard.instantiateViewControllerWithIdentifier("VIEW_NAME")
        // self.showViewController(vc as UIViewController, sender: vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("View loaded")
        // Load defaults
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("52d27bde-9418-4a5d-8528-3fb32e1a5d69", forKey: "userID")
        defaults.setObject("TestPassword", forKey: "userPassword")
        
        // Try log in with token
        // If token expired, refresh token
        let token = defaults.stringForKey("userToken")
        if token!.characters.count > 0
        {
            // We're good
            print("Token")
            print(token!)
            // logInWithToken
        } else {
            // Log in again and then refresh token
            let userName = defaults.stringForKey("userID")!
            let userPassword = defaults.stringForKey("userPassword")!
            let token = logUserIn(userName, userPassword: userPassword)
            
            // Set token if not blank
            defaults.setObject(token, forKey: "userToken")
        }

    }
    
    func logUserIn(userID: String, userPassword: String) -> String {
        let s   =   TCPIPSocket()
        let f   =   NSFileHandle(fileDescriptor: s.socketDescriptor)
        
        print("User: "+userID+" and password: "+userPassword)
        
        // @TODO: Does not work over TLS
        // http://stackoverflow.com/a/30648011
        
        // Vagrant: 192.168.33.110, port:
        s.connect(TCPIPSocketAddress(127, 0, 0, 1), 6600)
        //loginString = "0~appauth~2~52d27bde-9418-4a5d-8528-3fb32e1a5d69~TestPassword"
        f.writeData(("0~appauth~2~"+userID+"~"+userPassword as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        let d   =   f.readDataToEndOfFile()
        
        print(NSString(data: d, encoding: NSUTF8StringEncoding)!)
        
        var response = NSString(data: d, encoding: NSUTF8StringEncoding)! as String
        
        // Replace all newlines
        response = response.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        // @TODO Make this less hacky
        if response == "0~Authentication credentials invalid" {
            response = ""
        }
        
        print(response)
        
        return response
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

