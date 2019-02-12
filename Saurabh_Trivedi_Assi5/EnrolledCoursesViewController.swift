//
//  EnrolledCoursesViewController.swift
//  Saurabh_Trivedi_Assi5
//
//  Created by Trivedi on 11/18/18.
//  Copyright © 2018 Trivedi. All rights reserved.
//

import UIKit
import Alamofire

class EnrolledCoursesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var enrolledCoursesTableView: UITableView!
    let defaults = UserDefaults.standard
    var enrolledCoursesDataSource : Dictionary<String,Array<NSDictionary>> = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getClassIDs()
    }
    func getClassIDs(){
        let parameters: Parameters = [
            "redid":  defaults.value(forKey: "redId") as! String,
            "password" : defaults.value(forKey: "password") as! String
        ]
        Alamofire.request("https://bismarck.sdsu.edu/registration/studentclasses",method: .get, parameters: parameters).responseJSON { response in
            if let json = response.result.value {
                var courceIDs :Array<Int> = []
                courceIDs.append(contentsOf: ((json as! NSDictionary).value(forKey: "classes") as! [Int]))
                courceIDs.append(contentsOf: ((json as! NSDictionary).value(forKey: "waitlist") as! [Int]))
                self.getClassName(courceIDs: courceIDs, orignalData: (json as! NSDictionary))
            }
        }
    }
    func getClassName( courceIDs: Array<Int>, orignalData: NSDictionary){
        let parameters: Parameters = ["classids": courceIDs]
        Alamofire.request("https://bismarck.sdsu.edu/registration/classdetails", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in
            if let json = response.result.value {
                let coursesData = json as! NSArray
                let enrlloedClassesCount = (orignalData.value(forKey: "classes") as! [Int]).count
                let waitlistedClassesCount = (orignalData.value(forKey: "waitlist") as! [Int]).count
                var enrlloedClasses :Array<NSDictionary> = []
                var waitlistedClasses :Array<NSDictionary> = []
                for i in 0..<enrlloedClassesCount{
                    enrlloedClasses.append(coursesData[i] as! NSDictionary)
                }
                for i in enrlloedClassesCount..<enrlloedClassesCount+waitlistedClassesCount{
                    waitlistedClasses.append(coursesData[i] as! NSDictionary)
                }
                var enrolledCoursesData : Dictionary<String,Array<NSDictionary>> = [:]
                enrolledCoursesData["classes"] = enrlloedClasses
                enrolledCoursesData["waitlist"] = waitlistedClasses
                self.enrolledCoursesDataSource = enrolledCoursesData
                self.enrolledCoursesTableView.reloadData()

            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Enrolled classes"
        case 1:
            return "Waitlested Classes"
        default:
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return enrolledCoursesDataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            switch section {
            case 0:
                return enrolledCoursesDataSource["classes"]!.count
            case 1:
                return enrolledCoursesDataSource["waitlist"]!.count
            default:
                return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        switch indexPath.section {
        case 0:
            let course = enrolledCoursesDataSource["classes"]![indexPath.row] as NSDictionary
            cell.textLabel?.text = "\(course.object(forKey: "id")!) - \(course.object(forKey: "title")!)"
        case 1:
            let course = enrolledCoursesDataSource["waitlist"]![indexPath.row] as NSDictionary
            cell.textLabel?.text = "\(course.object(forKey: "id")!) - \(course.object(forKey: "title")!)"
        default:
            print("Default")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Drop Class", message: "Are you sure?", preferredStyle: .alert)
        
        switch indexPath.section {
        case 0:
            let course = enrolledCoursesDataSource["classes"]![indexPath.row] as NSDictionary
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .default, handler: { _ in
                self.removeEnrolledClass(courseID: course.object(forKey: "id")! as! Int)
            }))
        case 1:
            let course = enrolledCoursesDataSource["waitlist"]![indexPath.row] as NSDictionary
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .default, handler: { _ in
                self.removeWaitlistedClass(courseID: course.object(forKey: "id")! as! Int)
            }))
        default:
            break
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .cancel, handler: { _ in
            
        }))
       
        self.present(alert, animated: true, completion: nil)
      
    }
    
    func removeEnrolledClass(courseID:Int){
        let parameters: Parameters = [
            "redid":  defaults.value(forKey: "redId") as! String,
            "password" : defaults.value(forKey: "password") as! String,
            "courseid" :courseID
        ]
        Alamofire.request("https://bismarck.sdsu.edu/registration/unregisterclass",method: .get, parameters: parameters).responseJSON { response in
            if let json = response.result.value {
                var alert : UIAlertController
                if let result = (json as! NSDictionary).value(forKey: "error"){
                    alert = UIAlertController(title: "", message: result as? String, preferredStyle: .alert)
                }else {
                    alert = UIAlertController(title: "", message: "Successfully Class Droped", preferredStyle: .alert)
                }
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "Default action"), style: .default, handler: { _ in
                    self.getClassIDs()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    func removeWaitlistedClass(courseID:Int){
        let parameters: Parameters = [
            "redid":  defaults.value(forKey: "redId") as! String,
            "password" : defaults.value(forKey: "password") as! String,
            "courseid" :courseID
        ]
        Alamofire.request("https://bismarck.sdsu.edu/registration/unwaitlistclass",method: .get, parameters: parameters).responseJSON { response in
            if let json = response.result.value {
                var alert : UIAlertController
                if let result = (json as! NSDictionary).value(forKey: "error"){
                    alert = UIAlertController(title: "", message: result as? String, preferredStyle: .alert)
                }else {
                    alert = UIAlertController(title: "", message: "Successfully Class Droped", preferredStyle: .alert)
                }
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "Default action"), style: .default, handler: { _ in
                    self.getClassIDs()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func dropAllClasses(_ sender: Any) {
        let parameters: Parameters = [
            "redid":  defaults.value(forKey: "redId") as! String,
            "password" : defaults.value(forKey: "password") as! String
        ]
        Alamofire.request("https://bismarck.sdsu.edu/registration/resetstudent",method: .get, parameters: parameters).responseJSON { response in
            if let json = response.result.value {
                var alert : UIAlertController
                if let result = (json as! NSDictionary).value(forKey: "error"){
                    alert = UIAlertController(title: "", message: result as? String, preferredStyle: .alert)
                }else {
                    alert = UIAlertController(title: "", message: "All Courses Successfully Droped", preferredStyle: .alert)
                }
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "Default action"), style: .default, handler: { _ in
                     self.getClassIDs()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}
