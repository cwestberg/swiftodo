//
//  ViewController.swift
//  SwiftOdo
//
//  Created by Clarence Westberg on 10/30/15.
//  Copyright © 2015 Clarence Westberg. All rights reserved.
//

import UIKit
import GameController


class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: Properties
    @IBOutlet weak var factorLabel: UILabel!
    @IBOutlet weak var milesLbl: UILabel!
    @IBOutlet weak var horrizontalAccuracy: UILabel!
    @IBOutlet weak var omStepper: UIStepper!
    @IBOutlet weak var imLbl: UILabel!
    @IBOutlet weak var splitLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var directionControl: UISegmentedControl!
    @IBOutlet weak var countersControl: UISegmentedControl!
    
    @IBOutlet weak var factorStepper: UIStepper!
    var distanceType = "miles"
    var oldStepper = 0.0
    var items: [String] = []
    var actions: [String] = []
    var splitOM = 0.00
    var splitIM = 0.00
    var factor = 1.0000
    var distance = 0.0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        omStepper.maximumValue = 999.99
        omStepper.minimumValue = -999.99
        
        milesLbl.layer.borderColor = UIColor.blueColor().CGColor
        milesLbl.layer.borderWidth = 1
        milesLbl.layer.cornerRadius = 10
        imLbl.layer.borderColor = UIColor.blueColor().CGColor
        imLbl.layer.borderWidth = 1
        imLbl.layer.cornerRadius = 10
        self.factorLabel.text = "1.0000"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.split(_:)), name: "Split", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.locationAvailable(_:)), name: "LOCATION_AVAILABLE", object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.controllerDidConnect(_:)), name: "GCControllerDidConnectNotification", object: nil)

        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
//        self.tableView.registerClass(UITableViewCell.self,forCellReuseIdentifier:"cell")

    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        tableView.reloadData()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func controllerDidConnect(notification: NSNotification) {
        
        let controller = notification.object as! GCController
        print("controller is \(controller)")
        print("game on ")
        print("\(controller.gamepad!.buttonA.pressed)")

        controller.gamepad?.dpad.up.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed  && value > 0.2 {
                print("dpad.up")
                let userInfo = [
                    "action":"plusOne"]
                NSNotificationCenter.defaultCenter().postNotificationName("PlusOne", object: nil, userInfo: userInfo)
            }
        }
        
        controller.gamepad?.dpad.down.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed && value > 0.2  {
                print("dpad.up")
                let userInfo = [
                    "action":"minusOne"]
                NSNotificationCenter.defaultCenter().postNotificationName("MinusOne", object: nil, userInfo: userInfo)
            }
        }
        
        controller.gamepad?.dpad.left.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed  && value > 0.2 {
                print("dpad.left")
                let direction = "reverse"
                let userInfo = [
                    "action":"\(direction)"]
                NSNotificationCenter.defaultCenter().postNotificationName("DirectionChanged", object: nil, userInfo: userInfo)
                self.directionControl.selectedSegmentIndex = 1
            }
        }
        
        controller.gamepad?.dpad.right.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed && value > 0.2  {
                print("dpad.right")
                let direction = "forward"
                let userInfo = [
                    "action":"\(direction)"]
                NSNotificationCenter.defaultCenter().postNotificationName("DirectionChanged", object: nil, userInfo: userInfo)
                self.directionControl.selectedSegmentIndex = 0
            }
        }
        
        controller.gamepad?.buttonA.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("buttonA")
                let userInfo = [
                    "action":"reset"]
                NSNotificationCenter.defaultCenter().postNotificationName("Reset", object: nil, userInfo: userInfo)
            }
        }
        //        controller.gamepad?.rightShoulder
        controller.gamepad?.buttonB.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("buttonB")
                
                let userInfo = [
                    "action":"resetIM"]
                let zim = String(format: "%.2f", self.splitOM)
                self.items.insert("ZIM \(zim)", atIndex:0)
                self.tableView.reloadData()
                NSNotificationCenter.defaultCenter().postNotificationName("ResetIM", object: nil, userInfo: userInfo)
            }
        }

        controller.gamepad?.buttonY.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("buttonY")
                let userInfo = [
                    "action":"resetBoth"]
                NSNotificationCenter.defaultCenter().postNotificationName("ResetBoth", object: nil, userInfo: userInfo)
//                let counters = "both"
//                let userInfo = [
//                    "action":"\(counters)"]
//                NSNotificationCenter.defaultCenter().postNotificationName("SelectedCountersChanged", object: nil, userInfo: userInfo)
//                self.countersControl.selectedSegmentIndex = 1
            }
        }

        
        controller.gamepad?.buttonX.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                var counters = ""
                print("buttonX \(self.countersControl.selectedSegmentIndex)")
                var index = self.countersControl.selectedSegmentIndex
                index = index + 1
                if index == 3 {
                    self.countersControl.selectedSegmentIndex = 0
                }
                print("buttonX \(self.countersControl.selectedSegmentIndex)")
                self.countersControl.selectedSegmentIndex = index
                switch self.countersControl.selectedSegmentIndex {
                case 0:
                    counters = "om"
//                    self.countersControl.selectedSegmentIndex = 2
                case 1:
                    counters = "both"
//                    self.countersControl.selectedSegmentIndex = 1
                case 2:
                    counters = "im"
//                    self.countersControl.selectedSegmentIndex = 0
                default:
                    break;
                }

                
                let userInfo = [
                    "action":"\(counters)"]
                NSNotificationCenter.defaultCenter().postNotificationName("SelectedCountersChanged", object: nil, userInfo: userInfo)
            }
        }
        controller.gamepad?.rightShoulder.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("rightShoulder")
                self.items.insert(self.milesLbl.text!, atIndex:0)
                self.tableView.reloadData()
            }
        }
    }
    
    // Table

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.text = self.items[indexPath.row]
        cell.detailTextLabel!.text = self.actions[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")

    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            items.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    // End Table
    
    @IBAction func shareBtn(sender: UIButton) {
        self.share()
    }
    @IBAction func factorStepper(sender: UIStepper) {
        self.factor = sender.value
        self.factorLabel.text = String(format: "%.4f",self.factor)
        let userInfo = [
            "factor":factor]
        NSNotificationCenter.defaultCenter().postNotificationName("FACTOR_CHANGED", object: nil, userInfo: userInfo)
    }
    
    @IBAction func milesKMChanged(sender: AnyObject) {
        
        switch sender.selectedSegmentIndex
        {
        case 0:
            distanceType = "miles"
        case 1:
            distanceType = "km"
        default:
            break;
        }
        let userInfo = [
            "action":"\(distanceType)"]
        NSNotificationCenter.defaultCenter().postNotificationName("MilesKMSelectionChanged", object: nil, userInfo: userInfo)
    }
    
    func split(notification:NSNotification){
        let userInfo = notification.userInfo
//        print("split nofification \(userInfo)")
        let m = userInfo!["miles"]!
        items.insert(String(format: "%.2f", m as! Float64), atIndex:0)
        actions.insert("Split", atIndex:0)
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
//        print(sender)
//        print(sender.value)
//        print(oldStepper)
//        print(sender.value < oldStepper)
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
        let zim = String(format: "%.2f", self.splitOM)
        items.insert("\(zim)", atIndex:0)
        actions.insert("Zero IM", atIndex:0)
        self.tableView.reloadData()
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
        let splitDistance = self.distance

        let alertController = UIAlertController(title: "Actions", message: "Select Action to perform", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            //print(action)
        }
        alertController.addAction(cancelAction)
        
        let clearTable = UIAlertAction(title: "Clear Splits", style: .Destructive) {(action) in
            self.items.removeAll()
            self.tableView.reloadData()
        }
        alertController.addAction(clearTable)

        
        let zeroAction = UIAlertAction(title: "Reset Trip Meters", style: .Destructive) {(action) in
            let userInfo = [
               "action":"resetBoth"]
            NSNotificationCenter.defaultCenter().postNotificationName("ResetBoth", object: nil, userInfo: userInfo)
        }
        alertController.addAction(zeroAction)
    
        
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
        
        let setMileageAction = UIAlertAction(title: "Set Mileage", style: .Destructive) { (action) in
//            print("Set Mileage Btn pushed")
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
//                print("save: \(newMileage)")
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

//        self.presentViewController(alertController, animated: true) {
//            // ...
//        }
        
        let addNoteAction = UIAlertAction(title: "Add Note", style: .Destructive) { (action) in
            //Create the AlertController
            let alert: UIAlertController = UIAlertController(title: "Add Note", message: "Swiftly Now! Add Note", preferredStyle: .Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            alert.addAction(cancelAction)
            
            let saveAction = UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction!) in
                
                let textField = alert.textFields![0] as UITextField
//                print(textField.text!)
                self.items.insert("\(String(format: "%.2f", splitDistance))", atIndex:0)
                self.actions.insert("\(textField.text!)", atIndex:0)

                self.tableView.reloadData()
                
            })
            alert.addAction(saveAction)
            
            //Add a text field
            alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
                textField.text = ""
            }
            
            //Present the AlertController
            self.presentViewController(alert, animated: true, completion: nil)        }
        alertController.addAction(addNoteAction)
        
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
//        print("Odometer UserInfo: \(userInfo)")
//        print(userInfo!["miles"]!)
//        let m = userInfo!["miles"]!
//        self.splitOM = m as! Double
//        self.milesLbl.text = (String(format: "%.2f", m as! Float64))
//        let im = userInfo!["imMiles"]!
//        self.splitIM = im as! Double
//        self.imLbl.text = (String(format: "%.2f", im as! Float64))
        
        switch distanceType
        {
        case "miles":
            let m = userInfo!["miles"]!
            self.distance = m as! Float64
            self.milesLbl.text = (String(format: "%06.2f", m as! Float64))
            let im = userInfo!["imMiles"]!
            self.imLbl.text = (String(format: "%06.2f", im as! Float64))
        case "km":
            let d = userInfo!["km"]!
            self.distance = d as! Float64
            self.milesLbl.text = (String(format: "%06.2f", d as! Float64))
            let imD = userInfo!["imKM"]!
            self.imLbl.text = (String(format: "%06.2f", imD as! Float64))
        default:
            break;
        }
        
        horrizontalAccuracy.text = String(userInfo!["horizontalAccuracy"]!)
    }
    
    func share() {
        
        print("\(self.items)")
        var firstActivityItem = [String]()
//        _ = self.items
        for item in items {
            firstActivityItem.append(item)
        }
        
        //        let firstActivityItem = "\(self.splits)"
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: firstActivityItem, applicationActivities: nil)
        presentViewController(activityViewController, animated:true, completion: nil)
        
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

