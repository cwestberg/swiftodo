//
//  ViewController.swift
//  SwiftOdo
//
//  Created by Clarence Westberg on 10/30/15.
//  Copyright © 2015 Clarence Westberg. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: Properties
    @IBOutlet weak var factorLabel: UILabel!
    
    @IBOutlet weak var milesLbl: UILabel!
    @IBOutlet weak var etLbl: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var horrizontalAccuracy: UILabel!
    @IBOutlet weak var omStepper: UIStepper!
    @IBOutlet weak var imLbl: UILabel!
    @IBOutlet weak var splitLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!

    
    @IBOutlet weak var averageSpeedLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    var timer: NSTimer?
    var oldStepper = 0.0
    var items: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        omStepper.maximumValue = 999.99
        omStepper.minimumValue = -999.99

        self.factorLabel.text = "1.0000"
        self.splitLbl.text = "0.00"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "split:", name: "Split", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationAvailable:", name: "LOCATION_AVAILABLE", object: nil)

        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
            selector: "updateTimeLabel", userInfo: nil, repeats: true)
        
        self.tableView.registerClass(UITableViewCell.self,forCellReuseIdentifier:"cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Table

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.text = self.items[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")

    }
    // End Table
    
    func updateTimeLabel() {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        timeLbl.text = formatter.stringFromDate(NSDate())
    }

    func split(notification:NSNotification){
        let userInfo = notification.userInfo
        //print(userInfo!["miles"]!)
        let m = userInfo!["miles"]!
        self.splitLbl.text = (String(format: "%.2f", m as! Float64))
        items.insert(String(format: "%.2f", m as! Float64), atIndex:0)
        self.tableView.reloadData()
    }
    
    // MARK Actions
    
    
    @IBAction func splitBtn(sender: AnyObject) {
        let userInfo = [
            "action":"splitOM"]
        NSNotificationCenter.defaultCenter().postNotificationName("SplitOM", object: nil, userInfo: userInfo)
    }
    
    @IBAction func selectedCountersChanged(sender: AnyObject) {
//        SelectedCountersChanged
        var counters = ""
        switch sender.selectedSegmentIndex
        {
        case 0:
            counters = "om"
        case 1:
            counters = "both"
        case 2:
            counters = "im"
        default:
            break;
        }
        let userInfo = [
            "action":"\(counters)"]
        
        NSNotificationCenter.defaultCenter().postNotificationName("SelectedCountersChanged", object: nil, userInfo: userInfo)
    }
    @IBAction func direction(sender: AnyObject) {
        var direction = ""
        switch sender.selectedSegmentIndex
        {
        case 0:
            print("direction Btn pushed forward")
            direction = "forward"
        case 1:
            print("direction Btn pushed reverse")
            direction = "reverse"
        default:
            break; 
        }
        let userInfo = [
            "action":"\(direction)"]

        NSNotificationCenter.defaultCenter().postNotificationName("DirectionChanged", object: nil, userInfo: userInfo)

    }
    @IBAction func omStepper(sender: UIStepper) {
        print(sender)
        print(sender.value)
        print(oldStepper)
        print(sender.value < oldStepper)
        if sender.value < oldStepper{
            let userInfo = [
                "action":"minusOne"]
            NSNotificationCenter.defaultCenter().postNotificationName("MinusOne", object: nil, userInfo: userInfo)

        }
        else{
            let userInfo = [
                "action":"plusOne"]
            NSNotificationCenter.defaultCenter().postNotificationName("PlusOne", object: nil, userInfo: userInfo)
        }
        oldStepper = sender.value

    }
    
    @IBAction func zeroTimer(sender: AnyObject) {
        let userInfo = ["action":"zeroIntervalTime"]
        NSNotificationCenter.defaultCenter().postNotificationName("ZeroInterval", object: nil, userInfo: userInfo)
    }
    
    @IBAction func zeroOdo(sender: AnyObject) {
        //print("reset Btn pushed")
        let userInfo = [
            "action":"reset"]
        NSNotificationCenter.defaultCenter().postNotificationName("Reset", object: nil, userInfo: userInfo)
    }
    
    @IBAction func zeroIM(sender: AnyObject) {
        //print("zeroIM Btn pushed")
        let userInfo = [
            "action":"resetIM"]
        NSNotificationCenter.defaultCenter().postNotificationName("ResetIM", object: nil, userInfo: userInfo)
    }
   
    @IBAction func plusMileage(sender: AnyObject) {
        //print("+ Btn pushed")
        let userInfo = [
            "action":"plusOne"]
        NSNotificationCenter.defaultCenter().postNotificationName("PlusOne", object: nil, userInfo: userInfo)
    }
    
    @IBAction func minusMileage(sender: AnyObject) {
        //print("- Btn pushed")
        let userInfo = [
            "action":"minusOne"]
        NSNotificationCenter.defaultCenter().postNotificationName("MinusOne", object: nil, userInfo: userInfo)
    }
    
    @IBAction func dialogActions(sender: AnyObject) {
        let alertController = UIAlertController(title: "Actions", message: "Select Action to perform", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            //print(action)
        }
        alertController.addAction(cancelAction)
        
        let zeroAction = UIAlertAction(title: "Reset Trip Meters", style: .Destructive) {(action) in
            let userInfo = [
                "action":"resetBoth"]
            NSNotificationCenter.defaultCenter().postNotificationName("ResetBoth", object: nil, userInfo: userInfo)
        }
        alertController.addAction(zeroAction)
//        
//        let zeroIntervalAction = UIAlertAction(title: "Zero Interval Time", style: .Destructive) {(action) in
//            let userInfo = [
//                "action":"zeroIntervalTime"]
//            NSNotificationCenter.defaultCenter().postNotificationName("ZeroInterval", object: nil, userInfo: userInfo)
//        }
//        alertController.addAction(zeroIntervalAction)

    
        
        let setFactorAction = UIAlertAction(title: "Set Factor", style: .Destructive) { (action) in
            //print("Set Factor Btn pushed")
            //Create the AlertController
            let alert: UIAlertController = UIAlertController(title: "Set Factor", message: "Swiftly Now! Choose an option!", preferredStyle: .Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            alert.addAction(cancelAction)
            
            let saveAction = UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction!) in
                
                //let textField = alert.textFields![0] as UITextField
                let textField = alert.textFields![0] as UITextField
                self.factorLabel.text = textField.text
                
                textField.keyboardType = UIKeyboardType.NumberPad
                let factor = (textField.text! as NSString).floatValue
                //print("save: \(factor)")
                //            self.updateRating(textField.text)
                let userInfo = [
                    "factor":factor]
                NSNotificationCenter.defaultCenter().postNotificationName("FACTOR_CHANGED", object: nil, userInfo: userInfo)
            })
            alert.addAction(saveAction)
            
            //Add a text field
            alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
                textField.keyboardType = UIKeyboardType.DecimalPad
                textField.text = self.factorLabel.text
            }
            
            //Present the AlertController
            self.presentViewController(alert, animated: true, completion: nil)        }
        alertController.addAction(setFactorAction)
        
        // Remove this
        let setMileageAction = UIAlertAction(title: "Set Mileage", style: .Destructive) { (action) in
            print("Set Mileage Btn pushed")
            //Create the AlertController
            let alert: UIAlertController = UIAlertController(title: "Set Mileage", message: "Swiftly Now! Enter Mileage", preferredStyle: .Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            alert.addAction(cancelAction)
            
            let saveAction = UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction!) in
                
                let textField = alert.textFields![0] as UITextField
                
                textField.keyboardType = UIKeyboardType.NumberPad
                let newMileage = (textField.text! as NSString).floatValue
                print("save: \(newMileage)")
                let userInfo = [
                    "newMileage":newMileage]
                NSNotificationCenter.defaultCenter().postNotificationName("SetMileage", object: nil, userInfo: userInfo)
            })
           alert.addAction(saveAction)
            
            //Add a text field
            alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
                textField.keyboardType = UIKeyboardType.DecimalPad
                textField.text = ""
            }
        
            //Present the AlertController
            self.presentViewController(alert, animated: true, completion: nil)        }
        alertController.addAction(setMileageAction)

        self.presentViewController(alertController, animated: true) {
            // ...
        }

    }
    
    @IBAction func resetBtn(sender: AnyObject) {
        //print("reset Btn pushed")
        let userInfo = [
            "action":"reset"]
        NSNotificationCenter.defaultCenter().postNotificationName("Reset", object: nil, userInfo: userInfo)
    }
    
    @IBAction func setFactorBtn(sender: AnyObject) {
        //print("Set Factor Btn pushed")
        //Create the AlertController
        let alert: UIAlertController = UIAlertController(title: "Set Factor", message: "Swiftly Now! Choose an option!", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Do some stuff
        }
        alert.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction!) in
            
            //let textField = alert.textFields![0] as UITextField
            let textField = alert.textFields![0] as UITextField
            self.factorLabel.text = textField.text

            textField.keyboardType = UIKeyboardType.NumberPad
            let factor = (textField.text! as NSString).floatValue
            //print("save: \(factor)")
//            self.updateRating(textField.text)
            let userInfo = [
                "factor":factor]
            NSNotificationCenter.defaultCenter().postNotificationName("FACTOR_CHANGED", object: nil, userInfo: userInfo)
        })
        alert.addAction(saveAction)
        
        //Add a text field
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.keyboardType = UIKeyboardType.DecimalPad
            textField.text = self.factorLabel.text
        }
        
        //Present the AlertController
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func locationAvailable(notification:NSNotification) -> Void {
        let userInfo = notification.userInfo
        print("Odometer UserInfo: \(userInfo)")
        //print(userInfo!["miles"]!)
        let m = userInfo!["miles"]!
        self.milesLbl.text = (String(format: "%.2f", m as! Float64))
        let im = userInfo!["imMiles"]!
        self.imLbl.text = (String(format: "%.2f", im as! Float64))

        horrizontalAccuracy.text = String(userInfo!["horizontalAccuracy"]!)
        if userInfo?["speed"] != nil {
            speedLabel.text = String(userInfo!["speed"]!)
        }
        //print("locationAvailable user info: \(userInfo)")
        //print("nil: \(userInfo?["averageSpeed"] == nil)")
        if userInfo?["averageSpeed"] != nil {
            let averageSpeed = userInfo?["averageSpeed"]
            //print("average speed notified \(averageSpeed)")
            averageSpeedLbl.text = (String(format: "%.1f", averageSpeed as! Float64))
            let et = userInfo!["et"]!
            let etString = stringFromTimeInterval(et as! Double)
            print("etString \(etString)")
            etLbl.text = etString as String
//           etLbl.text = String(format: "%.2f",et as! Float64)
        }
    }
    
    func stringFromTimeInterval(interval:NSTimeInterval) -> NSString {
        
        let ti = NSInteger(interval)
        
//        let ms = Int((interval % 1) * 1000)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
//        return NSString(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
    }
}

