//
//  PayZenPayment.swift
//  lyraInAppDemo
//
//  Created by Lyra Network on 07/09/2018.
//  Copyright © 2018 Lyra Network. All rights reserved.
//

import Foundation
import WebKit

//Mark: - PayZenPaymentInformation struct

struct PayZenPaymentInformation {
    
    var email: String
    var amount: String
    var mode: String
    var lang: String
    var cardType: String
    var currency:String
    
    //MARK: - Initializers
    init(email:String, amount:String, mode:String, lang: String, cardType:String, currency: String){
        self.amount = amount
        self.email = email
        self.mode = mode
        self.lang = lang
        self.cardType = cardType
        self.currency = currency
        
    }
}
    
//MARK: - PayZenPaymentDelegate protocol

/// Protocol for notifying the completion of the payment process. Client applications must conform this protocol.
protocol PayZenPaymentDelegate: class {
    
    /// Method to notifying classes that conform the protocol when the payment process is complete
    ///
    /// - Parameter error: If error have value means that the payment process failed
    func didPaymentServiceFinish(error: NSError?)
}

//MARK: - PayZenPayment class

/// Encapsulate the functionalities related to the payment process. Client applications should create an instance of this class and invoke the executePayment method.
class PayZenPayment: PaymentDelegate {
    
    //MARK: - Variables
    var paymentInfo: PayZenPaymentInformation
    weak var payZenPaymentDelegate: PayZenPaymentDelegate?
    
    //MARK: - Error Code
    static let ERROR_DOMAIN = "com.lyra.InApp"
    
    static let ERROR_UNKNOW = (errorCode: 1, errorMsg: "Unknow Error.")
    static let ERROR_TIMEOUT = (errorCode: 2, errorMsg: "Timeout error.")
    static let ERROR_NO_CONNECTION = (errorCode: 3, errorMsg: "No connection error.")
    static let ERROR_SERVER = (errorCode: 4, errorMsg: "Server marchand error.")
    static let ERROR_PAYMENT_CANCELATION = (errorCode: 5, errorMsg:"Payment cancelled.")
    static let ERROR_PAYMENT_REFUSED = (errorCode: 6, errorMsg:"Payment refused.")
    
    //MARK: - Configurations
    //FIXME: Change by the right payment server url
    static let SERVER_URL = "<REPLACE_ME>"
    
    //MARK: - Initializer
    init(paymentInfo: PayZenPaymentInformation) {
        self.paymentInfo = paymentInfo
    }
    
    //MARK: - Payment context methods
    
    /// Build an URLRequest according required payment information : server url, email, amount, mode, lang
    ///
    /// - Returns: URLRequest object
    func buildRequest() -> URLRequest? {
        let serverUrl: NSURL = NSURL(string: PayZenPayment.SERVER_URL)!
        var urlRequest = URLRequest(url:serverUrl as URL)
        urlRequest.httpMethod = "POST"
        var params: [String: String] = ["amount": paymentInfo.amount, "currency": paymentInfo.currency, "mode": paymentInfo.mode, "language": paymentInfo.lang]
        if !paymentInfo.email.isEmpty{
            params["email"] = paymentInfo.email
        }
        if !paymentInfo.cardType.isEmpty{
            params["cardType"] = paymentInfo.cardType
        }
       do{
            let jsonParam = try JSONSerialization.data(withJSONObject: params, options: [])
            urlRequest.httpBody = jsonParam
        }
        catch{
            return nil
        }
        
        return urlRequest
    }
    
    /// Call server to get payment url, supply a block completion (callback)
    ///
    /// - Returns: status boolean, payment url
    func getPaymentContext(completion: @escaping (Bool, String, NSError?) -> ()){
        // Build request
        let urlRequest = buildRequest()
        // Call server to obtain a payment Url
        // Completion is a callback, giving call status, and payment url if success
        if let request = urlRequest{
            let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                if error != nil{
                    completion(false, "", NSError.init(domain:PayZenPayment.ERROR_DOMAIN, code: PayZenPayment.ERROR_NO_CONNECTION.errorCode, userInfo: [NSLocalizedFailureReasonErrorKey: PayZenPayment.ERROR_NO_CONNECTION.errorMsg]))
                }
                if let httpResponse = response as? HTTPURLResponse {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                    var redirectionUrl = ""
                    var errorMsg = ""
                    if let jsonResponse = json {
                        redirectionUrl = (jsonResponse!["redirectionUrl"] as? String)!
                        errorMsg = (jsonResponse!["errorMessage"] as? String)!
                    }
                    switch(httpResponse.statusCode){
                    case 200:
                        completion(true, redirectionUrl, nil)
                    case 400, 500:
                        completion(false, "", NSError.init(domain:PayZenPayment.ERROR_DOMAIN, code: PayZenPayment.ERROR_SERVER.errorCode, userInfo: [NSLocalizedFailureReasonErrorKey: PayZenPayment.ERROR_SERVER.errorMsg + errorMsg]) )
                    default:
                        completion(false, "", NSError.init(domain:PayZenPayment.ERROR_DOMAIN, code: PayZenPayment.ERROR_UNKNOW.errorCode, userInfo: [NSLocalizedFailureReasonErrorKey: PayZenPayment.ERROR_UNKNOW.errorMsg]))
                    }
                }
                else{
                    completion(false, "", NSError.init(domain:PayZenPayment.ERROR_DOMAIN, code: PayZenPayment.ERROR_TIMEOUT.errorCode, userInfo: [NSLocalizedFailureReasonErrorKey: PayZenPayment.ERROR_TIMEOUT.errorMsg]))
                }
            }
            task.resume()
        } else{
            completion(false, "", NSError.init(domain:PayZenPayment.ERROR_DOMAIN, code: PayZenPayment.ERROR_UNKNOW.errorCode, userInfo: [NSLocalizedFailureReasonErrorKey: PayZenPayment.ERROR_UNKNOW.errorMsg]))
        }
    }
    
    //MARK: - Payment methods
    
    /// Execute payment via webView.
    ///
    /// - Parameter contextView: ViewController from which the payment process is triggered.
    func execute(contextView: UIViewController) {
        getPaymentContext { paymentContextGetted, redirectUrl, error in
            if !paymentContextGetted {
                if let error = error{
                    self.payZenPaymentDelegate?.didPaymentServiceFinish(error: error)
                }else{
                    self.payZenPaymentDelegate?.didPaymentServiceFinish(error: NSError.init(domain:PayZenPayment.ERROR_DOMAIN, code: PayZenPayment.ERROR_UNKNOW.errorCode, userInfo: [NSLocalizedFailureReasonErrorKey: PayZenPayment.ERROR_UNKNOW.errorMsg]))
                }
            } else{
                DispatchQueue.main.async(){
                    let controller = PaymentViewController()
                    controller.paymentInfo = self.paymentInfo
                    controller.urlPayment = redirectUrl
                    controller.paymentDelegate = self
                    contextView.present(controller, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    //MARK: - PaymentDelegate methos
    func didPaymentProcessFinish(error: NSError?) {
        payZenPaymentDelegate?.didPaymentServiceFinish(error: error)
    }
    
}
