//
//  ViewController.swift
//  EmoticonKeyBoard
//
//  Created by Pack Zhang on 16/5/1.
//  Copyright © 2016年 Pack Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBAction func btnClick(sender: UIBarButtonItem) {
        
        print(textView.loadStringFromTextViewAttributeString())
        
    }
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.inputView = emoticonVC.view
        
    }
    
    lazy var emoticonVC: ZYEmoticonViewController = {
        let vc = ZYEmoticonViewController()
        
        vc.textView = self.textView
        
        return vc
    }()
    
}
