//
//  CourseDetailsViewController.swift
//  Saurabh_Trivedi_Assi5
//
//  Created by Trivedi on 11/3/18.
//  Copyright © 2018 Trivedi. All rights reserved.
//

import UIKit
import Alamofire

class CourseDetailsViewController: UIViewController, UITableViewDataSource {
  
    var courseID :Int = 0
    var waitlist : Int = 0
    var courseDetails: NSDictionary = [:]
    let defaults = UserDefaults.standard
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var courseDetailsTableView: UITableView!
    @IBOutlet weak var addCourseButton: UIButton!
    var courseDetailsDataSource : Array<(key: Any, value: Any)> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        courseID = courseDetails.value(forKey: "id") as! Int
        courseDetailsDataSource = Array(courseDetails)
        courseTitle.text = courseDetails.value(forKey: "title") as? String
        if waitlist > 0 {
               addCourseButton.setTitle("Add To waitlist", for: UIControl.State.normal)
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if "\(courseDetailsDataSource[indexPath.row].key)" == "title"{
            //disable this
        }
        cell.textLabel?.text = "\(courseDetailsDataSource[indexPath.row].key) - \(courseDetailsDataSource[indexPath.row].value)"
        return cell
    }
    
    @IBAction func addCourse(_ sender: Any) {
        if waitlist > 0 {
            addToWaitlist()
        }else{
            addCourse()
        }
        
    
    }
    func addCourse(){
        let parameters: Parameters = [
            "redid":  defaults.value(forKey: "redId") as! String,
            "password" : defaults.value(forKey: "password") as! String,
            "courseid" :courseID
        ]
        Alamofire.request("https://bismarck.sdsu.edu/registration/registerclass",method: .get, parameters: parameters).responseJSON { response in
            if let json = response.result.value {
                var alert : UIAlertController
                if let result = (json as! NSDictionary).value(forKey: "error"){
                    alert = UIAlertController(title: "", message: result as? String, preferredStyle: .alert)
                }else {
                    alert = UIAlertController(title: "", message: "Successfully Class Added", preferredStyle: .alert)
                }
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "Default action"), style: .default, handler: { _ in
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    func addToWaitlist(){
        let parameters: Parameters = [
            "redid":  defaults.value(forKey: "redId") as! String,
            "password" : defaults.value(forKey: "password") as! String,
            "courseid" :courseID
        ]
        Alamofire.request("https://bismarck.sdsu.edu/registration/waitlistclass",method: .get, parameters: parameters).responseJSON { response in
            if let json = response.result.value {
                var alert : UIAlertController
                if let result = (json as! NSDictionary).value(forKey: "error"){
                    alert = UIAlertController(title: "", message: result as? String, preferredStyle: .alert)
                }else {
                    alert = UIAlertController(title: "", message: "Successfully Class Added", preferredStyle: .alert)
                }
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "Default action"), style: .default, handler: { _ in
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }

}
