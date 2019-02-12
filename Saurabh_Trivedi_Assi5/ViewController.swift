//
//  ViewController.swift
//  Saurabh_Trivedi_Assi5
//
//  Created by Trivedi on 11/3/18.
//  Copyright © 2018 Trivedi. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var emailId: UITextField!
    @IBOutlet weak var redId: UITextField!
    @IBOutlet weak var password: UITextField!
    var shouldPerfromSegue = false
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func register(_ sender: Any) {
        let parameters: Parameters = [
            "firstname": firstName.text!,
            "lastname" : lastName.text!,
            "redid" : redId.text!,
            "password" : password.text!,
            "email" : emailId.text!
        ]
        Alamofire.request("https://bismarck.sdsu.edu/registration/addstudent", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in
            if let json = response.result.value {
                let result = json as! NSDictionary
                if let value  = result.value(forKey: "error"){
                    self.showAlert(messege: value as! String)
                }else if let value = result.value(forKey: "ok"){
                    self.saveData(messege:value as! String)
                }
            }
        }
    }
    func  saveData(messege : String){
        let defaults = UserDefaults.standard
        defaults.set(firstName.text, forKey: "firstName")
        defaults.set(emailId.text, forKey: "emailId")
        defaults.set(redId.text, forKey: "redId")
        defaults.set(password.text, forKey: "password")
        defaults.set(lastName.text, forKey: "lastName")
        shouldPerfromSegue = true
        let alert = UIAlertController(title: "", message: messege, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "Default action"), style: .default, handler: { _ in
            self.performSegue(withIdentifier: "toCourseList", sender: self)
        }))
        self.present(alert, animated: true, completion: nil)
    
    }
    func showAlert(messege: String){
        let alert = UIAlertController(title: "", message: messege, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

