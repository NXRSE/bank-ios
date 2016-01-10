//
//  PaymentController.swift
//  Bank
//
//  Created by Kyle Redelinghuys on 2016/01/10.
//  Copyright © 2016 Kyle Redelinghuys. All rights reserved.
//
import Foundation
import UIKit

class PaymentController: UIViewController {

    @IBOutlet weak var PaymentAmount: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var RecipientLabel: UILabel!
    
    @IBAction func SubmitPayment(sender: AnyObject) {
        let paymentAmount = PaymentAmount.text
        
        print(paymentAmount)
        
        if (paymentAmount?.characters.count == 0) {
            ErrorLabel.text = "Please enter in a number"
            PaymentAmount.text = ""
        }
        
        // Cast to float
        let paymentFloat = (paymentAmount! as NSString).floatValue
        print(paymentFloat)
        // @TODO: Make sure this can be a float
        let token = NSUserDefaults.standardUserDefaults().stringForKey("userToken")!
        let senderAccountNumber = NSUserDefaults.standardUserDefaults().stringForKey("userID")!
        let recipientAccountNumber = NSUserDefaults.standardUserDefaults().stringForKey("paymentRecipientAccountNumber")!
        
        let paymentResult = TCPClient.doMakePayment(token, senderAccountNumber: senderAccountNumber, recipientAccountNumber: recipientAccountNumber, senderBankNumber: "", recipientBankNumber: "",  paymentAmount: paymentFloat)
        
        print(paymentResult)
        // @FIXME: Make this a real response
        if paymentResult != "true" {
            ErrorLabel.text = paymentResult
            return
        }
        
        NSUserDefaults.standardUserDefaults().setObject("Payment made successfully", forKey: "flashMessage")
        
        // Load view
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("AccountLanding")
        self.showViewController(vc as! UIViewController, sender: vc)
    }
    
    override func viewDidLoad() {
        let recipientName = NSUserDefaults.standardUserDefaults().stringForKey("paymentRecipientAccountHolderName")!
        RecipientLabel.text = "Recipient: " + recipientName
    }
    
    override func didReceiveMemoryWarning() {
        
    }
}
