# Webview Payment integration example

## Summary

Based on [PayZen](https://payzen.io), the aim of this repository is to explain how mobile payment by [Lyra Network](https://www.lyra-network.com/) webview can be done easily.

In this repo, Credit Card scanning by mobile camera is demonstrated too.

**Please, notice that the library used for this additional feature is not developped by Lyra Network. Lyra Network does not guarantee and is not responsible for the quality of this external library.**
**Moreover, be aware that the use of this librairy is not PCI-DSS compliant.**

## Table of contents

* [How it works](#how_it_is_work)
* [Getting started](#getting_started)
* [Additional feature](#features)
* [Technology](#technology)
* [Troubleshooting](#troubleshooting)
* [Copyright and license](#copyright)

<span id="how_it_is_work"></span>
## How it works

To be able to do some payments with PayZen, two elements are required:

* A contract with your Payment service provider.
* A mobile app with a PayZen integration: this integration is explained with this repository.
* A merchant server that executes payments transactions with PayZen servers: [merchant server demonstration](https://github.com/lyra/webview-payment-sparkjava-integration-sample).


More information about implementation on our online documentation https://payzen.io/fr-FR/form-payment/m-payment/sitemap.html

<span id="getting_started"></span>
## Getting started


Two quick start options are available: executes this sample or integrates into your own application.


### Execute this sample

1. See merchant server repo, `https://github.com/lyra/webview-payment-sparkjava-integration-sample`. Follow steps of getting started chapter and run your server.

2. Clone the repo, `git clone https://github.com/lyra/webview-payment-ios-integration-sample.git`.

3. Change to Credit Card scanning branch, git checkout card_scanning.

4. Open the application with Xcode.

5. In PayZenPayment.swift class, modify the SERVER_URL value according your merchant server url.

6. Run 'pod install' from the root of the project to make sure you already have all the CardIO files required.

7. Run the application.



	
### Integration in an existing application

1. See merchant server repo, `https://github.com/lyra/webview-payment-sparkjava-integration-sample`. Follow steps of getting started chapter and run your server.

2. Add the CardIO framework to your project. Follow the instructions in `https://github.com/card-io/card.io-iOS-SDK`.

3. Download PayZenPayment.swift and PaymentViewController.swift files, and import it your xcode project.

4. In PayZenPayment.swift class, modify the SERVER_URL value according your merchant server url.

5. Make the class from which the payment will be launched conforms the PayZenPaymentDelegate protocol. The didPaymentServiceFinish method tells the delegate that the payment is finish. An optional NSError value is used to indicate that the payment has not been made and the corresponding error message. Otherwise, the payment has been successfully completed.

    ```swift
    extension ViewController: PayZenPaymentDelegate{
        /// Tells the delegate that the payment is finish.
        ///
        /// - Parameter error: An optional NSError value indicating that the payment has not been made and the corresponding error message. Otherwise, the payment has been successfully completed.
        func didPaymentServiceFinish(error: NSError?) {
           
            //Through this function your application will be notified once the payment process has concluded. Implement here the behavior to follow for your application
        }
    }
    ```

6. Call the execute method to trigger the payment process. For this:

6.1. Create PayZenPaymentInformation object with required information for payment process:
  * email: *optional*, email
  *  amount: *mandatory*, the related amount
  *  mode: *mandatory*, TEST or PRODUCTION (your targeted environment)
  *  lang: *mandatory*, the language in which you want the payment pages to be displayed. 
  *  cardType: *optional*, can be CB, VISA, MASTERCARD, so on. If no provided, any card type will be proposed
  *  currency: *mandatory*, currency code, https://en.wikipedia.org/wiki/ISO_4217
	
```swift
	let paymentInfo = PayZenPaymentInformation(email: txtEmail.text!, amount: txtAmount.text!, mode: "TEST", lang: language, cardType: selectedCardType!, currency:"978")
```
	
6.2. Create PayZenPayment instance.
	
```swift
	payZenPayment = PayZenPayment(paymentInfo: paymentInfo)
```
	
6.3. Set PayZenPaymentDelegate. The class must implement the protocol PayZenPaymentDelegate to receive notifications of the completion of the payment process.
	
```swift
	payZenPayment?.payZenPaymentDelegate = self
```
6.4. Calling the execute method to trigger the payment process.
	
```swift
	payZenPayment?.execute(contextView: self)
```
7. Add to your .xcassets file a new image resource with "cardIo" as its name. This image will be used for the button corresponding to the card scanning functionality.

8. You should add the key NSCameraUsageDescription to your app's Info.plist and set the value to be a string describing why your app needs to use the camera. It is also necessary to add the NSPhotoLibraryUsageDescription permission.

<span id="technology"></span>	
## Technology

Tested in Xcode 10.0, written in Swift 4, webViewSample application require iOS 9.3 or superior.

<span id="troubleshooting"></span>	
## Troubleshooting

The following errors can occurred:

| Error  | Code | Cause |
| ------------- | ------------- | ------------- |
| ERROR_UNKNOW  | 1 | An unknown error has occurred. This error can occur when the url of merchant server is incorrect. Check that your url is syntactically correct. |
| ERROR_TIMEOUT  | 2 | A timeout error has occurred. This error can occur when your mobile is not able to communicate with your merchant server. Check that your server is up and is reachable. |
| ERROR_NO_CONNECTION  | 3 | A not connection error has occurred. This error can occur when your mobile is not connected to Internet (by Wifi or by mobile network). Check your mobile connection | 
| ERROR_SERVER  | 4 | A server error has occurred. This error can occur when your merchant server returns an invalid data. Check that your payment data sent are correct. |
| ERROR_PAYMENT_CANCELATION  | 5 | A payment cancelled error has occurred. This error can occur when user cancels he payment process. |
| ERROR_PAYMENT_REFUSED  | 6 | A payment refused error has occurred. This error can occur when payment is refused. Check the credit card used. |


<span id="copyright"></span>
## Copyright and license
	The MIT License

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.

	






