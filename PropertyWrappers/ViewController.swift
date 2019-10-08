//
//  ViewController.swift
//  PropertyWrappers
//
//  Created by Andrea Stevanato on 08/10/2019.
//  Copyright © 2019 Andrea Stevanato. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let post = Post(title: "    A title to trim     ", body: "    A body to trim      ")
        label.text = "\(post.title) - \(post.body)"
        
        AppSettings.isFirstLaunch = false
        
        APIManager.getCurrentWeather { result in
            print(result)
        }
    }
}
