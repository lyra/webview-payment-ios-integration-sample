//
//  PaymentViewController.swift
//  webViewSample
//
//  Created by Lyra Network on 09/10/2017.
//  Copyright © 2017 Lyra Network. All rights reserved.
//

import UIKit
import WebKit

//MARK: PaymentDelegate protocol

/// Protocol for notifying the completion of the payment process via WebView. PaymentProvider class conform this protocol.
protocol PaymentDelegate: class {
    func didPaymentProcessFinish(error: NSError?)
}

//MARK: - PaymentViewController class

/// Handle payment process inside webview
class PaymentViewController: UIViewController{
    
    //UI controls
    var webView: WKWebView!
    var activityIndicatorView: UIActivityIndicatorView?
    
    //payment process variables
    var urlPayment: String = ""
    var paymentInfo: PaymentInformation?
    weak var paymentDelegate: PaymentDelegate?
    
    var isFirstLoading: Bool = true
    
    // Constants
    let CALLBACK_URL_PREFIX = "http://webview"
    let URL_CONSTANT_TICKET = "getticket"
    let URL_CONSTANT_MENTIONS = "/mentions-paiement"
    let URL_CONSTANT_PDF = "%2Fpdf"
    let URL_CONSTANT_SECURITY = "/paiement-securise"
    
    //MARK: - ViewController life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showActivityIndicator()
        
        //urlPayment is the Url given by your payment platform
        let url = NSURL(string:self.urlPayment)
        let req = NSURLRequest(url:url! as URL)
        
        // We create and load a webview pointing to this Url
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.isNavigationBarHidden = true;
        self.webView!.load(req as URLRequest)
        self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.loading), options: .new, context: nil)
    }
    
    deinit{
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.loading))
        webView.navigationDelegate = nil
        webView.scrollView.delegate = nil
        webView.removeFromSuperview()
        webView = nil
    }
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
        self.webView = WKWebView()
        self.webView.navigationDelegate = self
        self.webView.scrollView.frame = self.webView.frame
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(20,0,0,0)
        self.webView.scrollView.delegate = self
        self.webView.scrollView.bounces = false
        self.webView.allowsBackForwardNavigationGestures = true   // Enable/Disable swiping to navigate
        self.view = self.webView
        
    }
    
    //MARK: - KVO WebView change method
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard (object as? WKWebView) != nil else {
            return
        }
        guard let keyPath = keyPath else {
            return
        }
        guard let change = change else {
            return
        }
        
        switch keyPath {
        case "loading":
            // Handle spinner stop when page has finished to load
            if let val = change[.newKey] as? Bool {
                if !val {
                    if isFirstLoading {
                        self.hideActivityIndicator()
                        isFirstLoading = false
                    }
                }
            }
        default:
            break
        }
    }
    
    //MARK: - Utils methods
    
    func isUrlToOpenedSeparately(url: String) -> Bool {
        return url.contains(URL_CONSTANT_TICKET) || url.contains(URL_CONSTANT_MENTIONS) || url.contains(URL_CONSTANT_PDF) || url.contains(URL_CONSTANT_SECURITY)
    }
    
    /// Notify end of payment, find payment status and notify to PaymentDelegate
    func notifyPaymentFinish(navigationAction: WKNavigationAction){
        let webViewUrlResponse = self.buildWebviewUrlResponse(navigationAction: navigationAction)
        var error: NSError?
        switch webViewUrlResponse.paymentStatus {
        case "success":
            error = nil
        case "cancel":
            error = NSError.init(domain: PaymentProvider.ERROR_DOMAIN, code: PaymentProvider.ERROR_PAYMENT_CANCELATION.errorCode, userInfo: [NSLocalizedFailureReasonErrorKey: PaymentProvider.ERROR_PAYMENT_CANCELATION.errorMsg])
        case "refused":
            error = NSError.init(domain:PaymentProvider.ERROR_DOMAIN, code: PaymentProvider.ERROR_PAYMENT_REFUSED.errorCode, userInfo: [NSLocalizedFailureReasonErrorKey: PaymentProvider.ERROR_PAYMENT_REFUSED.errorMsg])
        default:
            error = NSError.init(domain:PaymentProvider.ERROR_DOMAIN, code: PaymentProvider.ERROR_UNKNOW.errorCode, userInfo: [NSLocalizedFailureReasonErrorKey: PaymentProvider.ERROR_UNKNOW.errorMsg])
            
        }
        self.dismiss(animated: true) {
            self.paymentDelegate?.didPaymentProcessFinish(error: error)
        }
    }
    
    /// Indicate if current url contains CALLBACK_URL_PREFIX
    func isCallBackUrl(url: String) -> Bool {
        return url.contains(CALLBACK_URL_PREFIX)
    }
    
    /// Split the url contenu inside the WKNavigationAction object for get the payment status
    func buildWebviewUrlResponse(navigationAction: WKNavigationAction) -> (paymentStatus:String, dataQuery: [String:Any]){
        let arrayHost = navigationAction.request.url?.host?.components(separatedBy: ".")
        let paymentStatus = arrayHost?[(arrayHost?.count)!-1]
        if let paramsQueryArray = navigationAction.request.url?.query?.components(separatedBy:"&") {
            var dataQueryArray = [String:Any]()
            for row in paramsQueryArray {
                let pairs = row.components(separatedBy:"=")
                dataQueryArray[pairs[0]] = pairs[1]
            }
            return (paymentStatus!, dataQueryArray)
        }
        return (paymentStatus!, [String:Any]())
    }
    
    //MARK: - Activity Indicator methods
    
    /// Present activity indicator to the view
    func showActivityIndicator() {
        
        self.hideActivityIndicator()
        //create activity indicator view
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView?.color = UIColor.black
        activityIndicatorView?.hidesWhenStopped = true
        //adding activity indicator in view
        self.view.addSubview(activityIndicatorView!)
        //adding constraint to activity indicator for center in view
        activityIndicatorView?.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: activityIndicatorView!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: activityIndicatorView!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
        //starting activity indicator
        activityIndicatorView?.startAnimating()
    }
    
    /// Remove activity indicator from the view.
    func hideActivityIndicator() {
        //check if activity indicator exist and remove from the view
        if let activityView = activityIndicatorView {
            activityView.stopAnimating()
            activityView.removeFromSuperview()
            activityIndicatorView = nil
        }
    }
}

// MARK: - Extension ScrollView delegate
extension PaymentViewController: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        // Disable zoom in webviews
        return nil
    }
}

// MARK: - Extension WKNavigationDelegate
extension PaymentViewController: WKNavigationDelegate{
    
    /// Callback when an url change inside webview
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void){
        print(navigationAction.request.url?.absoluteString ?? "")
        // Cause html link with "target = _blank"
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        // We detect end of payment
        if isCallBackUrl(url: (navigationAction.request.url?.absoluteString)!) {
            decisionHandler(.cancel)
            notifyPaymentFinish(navigationAction: navigationAction)
            // We detect a page that should be open in a separate browser
        }else if isUrlToOpenedSeparately(url: (navigationAction.request.url?.absoluteString)!) {
            decisionHandler(.cancel)
            UIApplication.shared.openURL(navigationAction.request.url!)
            // We detect that a link in expiration page have been cliked
        }else{
            decisionHandler(.allow)
        }
    }
}
