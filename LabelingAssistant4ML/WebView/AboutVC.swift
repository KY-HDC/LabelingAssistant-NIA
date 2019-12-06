//
//  AboutVC.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 15/01/2019.
//  Copyright © 2019 uBiz Information Technology. All rights reserved.
//

import UIKit
import WebKit

class AboutVC: UIViewController, WKUIDelegate {

    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "About..."

        let myURL = URL(string: ServerWebView + "about")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
