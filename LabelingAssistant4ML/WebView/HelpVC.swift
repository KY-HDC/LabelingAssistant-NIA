//
//  HelpVC.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 15/01/2019.
//  Copyright © 2019 uBiz Information Technology. All rights reserved.
//

import UIKit
import WebKit

class HelpVC: UIViewController, WKUIDelegate {

    @IBOutlet var myNaviBar: UINavigationBar!
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "도움말"

        let description = "<p> HTML conent <p>"
        var headerString = "<header><meta name='viewport' content='width=100, initial-scale=2.0, maximum-scale=1.0, minimum-scale=1.0'></header>"
        headerString.append(description)
        webView.loadHTMLString("\(headerString)", baseURL: nil)
        
        let myURL = URL(string: ServerWebView + "help")
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
