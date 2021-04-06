//
//  ViewController.swift
//  TorusDirectAuthDemoApplication
//
//  Created by Shubham on 19/2/21.
//

import UIKit
import TorusSwiftDirectSDK
import PromiseKit
import SafariServices

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let button:UIButton = UIButton(frame: CGRect(x: 100, y: 400, width: 200, height: 50))
        button.backgroundColor = .black
        button.setTitle("Github Login", for: .normal)
        button.addTarget(self, action:#selector(self.buttonAction), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
        
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .github,
                                     clientId: "PC2a4tfNRvXbT48t89J5am0oFM21Nxff",
                                     verifierName: "torus-auth0-github-lrc",
                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                     browserRedirectURL: "https://scripts.toruswallet.io/redirect.html",
                                     jwtParams: ["domain":"torus-test.auth0.com"])

        let tdsdk = TorusSwiftDirectSDK(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-github-lrc", subVerifierDetails: [sub], loglevel: .info)
        
        // listening to notifications after redirect from browser
        // callback pattern is used because there are many ways to get the idToken from a service provider
        // for ex. Email redirect, browser, different app, same app but different component.
        
        // You can implement the same without observerCallback <> Notification pattern
        // Pass the idToken from AppDeletegate directly to sdk.getTorusKey()
        tdsdk.observeCallback{ url in
            let responseParameters = tdsdk.parseURL(url: url)
            sub.getUserInfo(responseParameters: responseParameters).then{ newData -> Promise<[String: Any]> in
                var data = newData
                let verifierId = data["verifierId"] as! String
                let idToken = data["tokenForKeys"] as! String
                data.removeValue(forKey: "tokenForKeys")
                data.removeValue(forKey: "verifierId")
                
                return tdsdk.getTorusKey(verifier: "torus-auth0-github-lrc", verifierId: verifierId, idToken: idToken, userData: data)
            }.done{data in
                print(data)
                // Do other tasks here
            }.catch{err in
                print(err)
                // In case of an error
            }
        }
        
        // Get the loginURL
        let loginURL = sub.getLoginURL()
        let handler = SFURLHandler(viewController: self)
        // Attach events here
        handler.presentCompletion = {
            print("Safari presented")
        }
        handler.dismissCompletion = {
            // Attach handler for dismissal
            print("Safari dismissed")
        }
        // trigger login using SFSafari browser
        handler.handle(URL(string: loginURL)!, modalPresentationStyle: modalPresentationStyle)
    }
    
    
}

