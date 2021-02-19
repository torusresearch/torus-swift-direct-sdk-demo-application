//
//  ViewController.swift
//  TorusDirectAuthDemoApplication
//
//  Created by Shubham on 19/2/21.
//

import UIKit
import TorusSwiftDirectSDK

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
        
        let tdsdk = TorusSwiftDirectSDK(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-github-lrc", subVerifierDetails: [sub], loglevel: .error)
        tdsdk.triggerLogin(browserType: .external).done{ data in
            print("private key rebuild", data)
            
            let alert = UIAlertController(title: "Public address", message: data["publicAddress"] as! String, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                            switch action.style{
                                                case .default:
                                                    print("default")
                                                    
                                                case .cancel:
                                                    print("cancel")
                                                    
                                                case .destructive:
                                                    print("destructive")
                                                    
                                                    
                                            }}))
            self.present(alert, animated: true, completion: nil)
            
        }.catch{ err in
            print(err)
        }
    }
    
    
}

