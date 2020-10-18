//
//  AboutViewController.swift
//  Unsplash
//
//  Created by Tarokh on 9/23/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    //MARK: - @IBOutlets
    
    //MARK: - Variables
    

    //MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.title = "About me"
        tabBarController?.navigationController?.navigationBar.prefersLargeTitles = false
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    //MARK: - Functions
    


}
