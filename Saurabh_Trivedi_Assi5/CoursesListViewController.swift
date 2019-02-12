//
//  CoursesListViewController.swift
//  Saurabh_Trivedi_Assi5
//
//  Created by Trivedi on 11/3/18.
//  Copyright © 2018 Trivedi. All rights reserved.
//

import UIKit
import Alamofire

class CoursesListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate{
    @IBOutlet weak var majorPickerView: UIPickerView!
    @IBOutlet weak var graduateLevelPickerView: UIPickerView!
    @IBOutlet weak var courseListTableView: UITableView!
    @IBOutlet weak var timingFilterPickerView: UIPickerView!
    var coursesListDataSource : [String] = []
    var coursesListDetails : NSArray = []
    var majorPickerViewDataSource : NSArray = []
    let graduateLevelPickerViewDataSource = ["All Level","Lower", "Upper", "Graduate"]
    let timingFilterPickerViewDataSource = ["06:00","07:00","08:00","09:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timingFilterPickerView.selectRow(timingFilterPickerViewDataSource.count - 1, inComponent: 1, animated: false)    
        self.getMajorList()
        let parameters: Parameters = ["subjectid":  8]
        self.getClassIDs(parameters: parameters)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == timingFilterPickerView{
            return 2
        }else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == majorPickerView{
            return majorPickerViewDataSource.count
        }else if pickerView == graduateLevelPickerView{
            return graduateLevelPickerViewDataSource.count
        }else{
            return timingFilterPickerViewDataSource.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == majorPickerView{
            return (majorPickerViewDataSource[row] as! NSDictionary).value(forKey: "title") as? String
        }else if pickerView == graduateLevelPickerView{
            return graduateLevelPickerViewDataSource[row]
        }else{
            return timingFilterPickerViewDataSource[row]
        }
    }
    
    func getClassIDs(parameters: Parameters){
        Alamofire.request("https://bismarck.sdsu.edu/registration/classidslist",method: .get, parameters: parameters).responseJSON { response in
            if let json = response.result.value {
                self.getClassName(courceIDs: json as! Array<Int>)
            }
        }
    }
    func getMajorList(){
        Alamofire.request("https://bismarck.sdsu.edu/registration/subjectlist", method: .get, encoding: JSONEncoding.default).responseJSON{ response in
            if let json = response.result.value {
                self.majorPickerViewDataSource = json as! NSArray
                self.majorPickerView.reloadAllComponents()
            }
        }
    }
    
    func getClassName( courceIDs: Array<Int>){
        let parameters: Parameters = ["classids": courceIDs]
        Alamofire.request("https://bismarck.sdsu.edu/registration/classdetails", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in
            var resultList : [String] = []
            if let json = response.result.value {
                let resultArray = json as! NSArray
                self.coursesListDetails = resultArray
                for element in resultArray{
                    let resultObject =  element as! NSDictionary
                    resultList.append("\(resultObject.object(forKey: "id")!) - \(resultObject.object(forKey: "title")!)")
                }
                self.coursesListDataSource = resultList
                self.courseListTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coursesListDataSource.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(coursesListDataSource[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toCourseDetailSegue", sender: indexPath)
        //Default should be self, if anytime system creshes
    }
    
    @IBAction func applyFilter(_ sender: Any) {
        let subjectId = (majorPickerViewDataSource[majorPickerView.selectedRow(inComponent: 0)] as! NSDictionary).value(forKey: "id") as? Int
        let parameters: Parameters = [
            "subjectid": subjectId!,
            "level": (graduateLevelPickerViewDataSource[graduateLevelPickerView.selectedRow(inComponent: 0)]).lowercased(),
            "starttime":(timingFilterPickerViewDataSource[timingFilterPickerView.selectedRow(inComponent: 0)]).replacingOccurrences(of: ":", with: ""),
            "endtime":(timingFilterPickerViewDataSource[timingFilterPickerView.selectedRow(inComponent: 1)]).replacingOccurrences(of: ":", with: "")
        ]
        self.getClassIDs(parameters: parameters)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCourseDetailSegue") {
            let viewController = segue.destination as! CourseDetailsViewController
            let indexPath = sender as! IndexPath
            let coursesDetailsDictionary = coursesListDetails[indexPath.row] as! NSDictionary
            viewController.courseDetails = coursesDetailsDictionary
            viewController.waitlist = coursesDetailsDictionary.value(forKey: "waitlist") as! Int
            
        }
    }
    @IBAction func backToCourseList(unwindSegue:UIStoryboardSegue){
        
    }
}
