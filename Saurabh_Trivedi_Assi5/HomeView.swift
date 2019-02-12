//
//  HomeView.swift
//  Saurabh_Trivedi_Assi5
//
//  Created by Trivedi on 11/11/18.
//  Copyright © 2018 Trivedi. All rights reserved.
//

import UIKit

class HomeView: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var viewCoursesButton: UIButton!
    @IBOutlet weak var enrolledCoursesButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.string(forKey: "redId") == nil {
            nameLabel.isHidden = true
            viewCoursesButton.isHidden = true
            enrolledCoursesButton.isHidden = true
        }else{
            nameLabel.isHidden = false
            viewCoursesButton.isHidden = false
            enrolledCoursesButton.isHidden = false
        }
        
        if let name = UserDefaults.standard.string(forKey: "firstName"){
            nameLabel.text = "Hi ,\(name)"
        }
    }
 
    @IBAction func backToHome(unwindSegue:UIStoryboardSegue){
        viewDidLoad()
    }

}
