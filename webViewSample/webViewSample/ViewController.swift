//
//  ViewController.swift
//  webViewSample
//
//  Created by Lyra Network on 13/09/2018.
//  Copyright © 2018 Lyra Network. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //UI controls
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnSelectCardTypes: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    
    var paymentProvider: PaymentProvider?
    
    //MARK: - ViewController life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        txtAmount.delegate = self
        txtEmail.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //CardIO speed up
        CardIOUtilities.preload()
    }
    
    //MARK: - Action methods
    
    @IBAction func payAction(_ sender: UIButton) {
        
        //hiding the keyboard
        txtAmount.resignFirstResponder()
        txtEmail.resignFirstResponder()
        
        let language = Locale.preferredLanguages[0].components(separatedBy: "-").first ??  Locale.preferredLanguages[0]
        var selectedCardType = btnSelectCardTypes.title(for:.normal)
        if selectedCardType == "All"{
            selectedCardType = ""
        }
        
        //show loading view
        self.loadingView.isHidden = false
        self.activityIndicatorView.startAnimating()
        
        //MARK: WebView Payment Integration Code
    
        //1.Create PaymentInformation object with required information for payment process
        //There are two options for the mode: TEST or PRODUCTION
        let paymentInfo = PaymentInformation(email: txtEmail.text!, amount: txtAmount.text!, mode: "TEST", lang: language, cardType: selectedCardType!, currency:"978")
        
        //2.Create a PaymentProvider instance
        paymentProvider = PaymentProvider(paymentInfo: paymentInfo)
        
        //3.Set PaymentProviderDelegate. The class must implement the protocol PaymentProviderDelegate to receive notifications of the completion of the payment process.
        paymentProvider?.paymentProviderDelegate = self
        
        //4.Calling the executePayment method to trigger the payment process.
        paymentProvider?.execute(contextView: self)
    }
    
    /// Action method for the select card type button. Displays a UIAlertController with card types to select.
    @IBAction func selectCardType(_ sender: UIButton) {
        
        let cardTypesController = UIAlertController(title: "Cards Types", message: "Select the supported card types", preferredStyle: .actionSheet)
        
        let allCardSupportedAction = UIAlertAction(title: "All", style: .default, handler:{(action) -> Void in  self.btnSelectCardTypes.setTitle("All", for: UIControlState.normal)
        })
        
        let visaCardSupportedAction = UIAlertAction(title: "Visa", style: .default, handler:{(action) -> Void in  self.btnSelectCardTypes.setTitle("Visa", for: UIControlState.normal)
        })
        
        let mastercardCardSupportedAction = UIAlertAction(title: "Mastercard", style: .default, handler:{(action) -> Void in  self.btnSelectCardTypes.setTitle("Mastercard", for: UIControlState.normal)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler:nil)
        
        cardTypesController.addAction(allCardSupportedAction)
        cardTypesController.addAction(visaCardSupportedAction)
        cardTypesController.addAction(mastercardCardSupportedAction)
        cardTypesController.addAction(cancelAction)
        
        self.present(cardTypesController, animated: true, completion: nil)
        
    }
}

//MARK: - Extensions

extension ViewController: PaymentProviderDelegate {
    /// Tells the delegate that the payment is finish.
    ///
    /// - Parameter error: An optional NSError value indicating that the payment has not been made and the corresponding error message. Otherwise, the payment has been successfully completed.
    func didPaymentServiceFinish(error: NSError?) {
        DispatchQueue.main.async(){
            //hiding loading view
            self.activityIndicatorView.stopAnimating()
            self.loadingView.isHidden = true
            var message = "Payment successful"
            if let error = error {
                message = "Payment failed. \(error.userInfo[NSLocalizedFailureReasonErrorKey] as! String)"
                
            }
            let alert = UIAlertController(title: "Information", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
