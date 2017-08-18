//
//  ViewController.swift
//  AngKeyChain
//
//  Created by skyphinehas@hanmail.net on 08/18/2017.
//  Copyright (c) 2017 skyphinehas@hanmail.net. All rights reserved.
//

import UIKit
import AngKeyChain

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        print("uuid = \(AngKeychain.uuid)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

