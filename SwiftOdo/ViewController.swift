//
//  ViewController.swift
//  SwiftOdo
//
//  Created by Clarence Westberg on 10/30/15.
//  Copyright © 2015 Clarence Westberg. All rights reserved.
//

import UIKit
import GameController
import CoreLocation

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
    let delegate = UIApplication.shared.delegate as? AppDelegate
    var xgpsConnected = false
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        omStepper.maximumValue = 999.99
        omStepper.minimumValue = -999.99
        
        milesLbl.layer.borderColor = UIColor.blue.cgColor
        milesLbl.layer.borderWidth = 1
        milesLbl.layer.cornerRadius = 10
        imLbl.layer.borderColor = UIColor.blue.cgColor
        imLbl.layer.borderWidth = 1
        imLbl.layer.cornerRadius = 10
        self.factorLabel.text = "1.0000"
        if let xgps160 = delegate?.xgps160 {
            let isConnected = (xgps160.isConnected)
            delegate?.coreLocationController?.xgpsConnected = isConnected
            xgpsConnected = isConnected}
        else {
            
        }

//        delegate?.coreLocationController?.xgpsConnected = (delegate?.xgps160!.isConnected)!
//        xgpsConnected = (delegate?.xgps160?.isConnected)!
  
        let omTap = UITapGestureRecognizer()
        omTap.addTarget(self, action: #selector(ViewController.splitFunc(sender:)))
        milesLbl.addGestureRecognizer(omTap)
        
        let imTap = UITapGestureRecognizer()
        imTap.addTarget(self, action: #selector(ViewController.splitImFunc(sender:)))
        imLbl.addGestureRecognizer(imTap)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.split(_:)), name: NSNotification.Name(rawValue: "Split"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.locationAvailable(_:)), name: NSNotification.Name(rawValue: "LOCATION_AVAILABLE"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.controllerDidConnect(_:)), name: NSNotification.Name(rawValue: "GCControllerDidConnectNotification"), object: nil)

        //        XGPS API

        EAAccessoryManager.shared().registerForLocalNotifications()

        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateUIWithNewPositionData(_:)), name: NSNotification.Name(rawValue: "PositionDataUpdated"), object: nil)
       
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.xgps160Connected(_:)), name: NSNotification.Name(rawValue: "XGPS160Connected") , object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.xgps160Disconnected(_:)), name: NSNotification.Name(rawValue: "XGPS160Disconnected"), object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIApplicationDelegate.applicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.accessoryDidDisconnect(_:)), name: NSNotification.Name(rawValue: "EAAccessoryDidDisconnectNotification") , object:nil)
        
        
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
//        self.tableView.registerClass(UITableViewCell.self,forCellReuseIdentifier:"cell")

    }

    func accessoryDidDisconnect(_ notification: Notification) {
        print("accessoryDidDisconnect")
        xgpsConnected = false
        delegate?.coreLocationController?.xgpsConnected = false
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        print("applicationDidBecomeActive notification")
        if let xgps160 = delegate?.xgps160 {
            delegate?.coreLocationController?.xgpsConnected = (delegate?.xgps160?.isConnected)!
            xgpsConnected = (xgps160.isConnected)
            print("isConnected? \(delegate?.xgps160!.isConnected)")
            print("xgpsConnected? \(xgpsConnected)")
            print("coreLocation connectd \(delegate?.coreLocationController?.xgpsConnected)")
            updateXgpsConnected()
            
        }
//        delegate?.coreLocationController?.xgpsConnected = (delegate?.xgps160?.isConnected)!
//        xgpsConnected = (delegate?.xgps160?.isConnected)!
//        print("isConnected? \(delegate?.xgps160!.isConnected)")
//        print("xgpsConnected? \(xgpsConnected)")
//        print("coreLocation connectd \(delegate?.coreLocationController?.xgpsConnected)")
//        updateXgpsConnected()
    }
    
    func updateXgpsConnected() {
        if xgpsConnected == true {
            
//            self.actions.insert("Connected", atIndex: 0)
//            self.items.insert("XGPS", atIndex:0)
//            self.tableView.reloadData()

        }
        else {
//            self.xgpsConnectedLbl.text = ""
//            self.actions.insert("Disconnected", atIndex: 0)
//            self.items.insert("XGPS", atIndex:0)
//            self.tableView.reloadData()
        }
        
    }
    func xgps160Connected(_ notification:Notification) {
        print("xgp160Connected Notifiction")
        delegate?.coreLocationController?.xgpsConnected = true
        xgpsConnected = true
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.updateUIWithNewPositionData(_:)), name: "PositionDataUpdated", object: nil)
//        updateXgpsConnected()
    }
    func xgps160Disconnected(_ notification:Notification) {
        print("xgp160Disconnected Notification")
        delegate?.coreLocationController?.xgpsConnected = false
        xgpsConnected = false
        updateXgpsConnected()
    }
    
    func deviceDataUpdated(_ notification:Notification) {
        //        print("deviceDataUpdated")
    }

    
    func updateUIWithNewPositionData(_ notification:Notification) {
//        print("updateUIWithNewPositionData")
//        print(delegate!.xgps160!.utc)
//        print(delegate!.xgps160!.lat)
//        print(delegate!.xgps160!.lon)
        let latitude: CLLocationDegrees = Double(delegate!.xgps160!.lat)
        let longitude: CLLocationDegrees = Double(delegate!.xgps160!.lon)
        
        let location: CLLocation = CLLocation(latitude: latitude,
                                              longitude: longitude)

//            print(delegate?.xgps160!.hdop)
        guard let hdop = delegate?.xgps160!.hdop
            else {
                horrizontalAccuracy.text = "?"

                return
        }
//        let hdop = delegate?.xgps160!.hdop
//        print(hdop)
        horrizontalAccuracy.text = String(describing: hdop)

        if Double((hdop)) > 2.0 {
            print("hdop > 2 \(hdop)")
        }
//        print(delegate!.xgps160!.waasInUse)
        
        if ((delegate?.xgps160!.speedAndCourseIsValid) != nil) && delegate?.xgps160!.fixType == 3
        {
            if Double(hdop) > 2.0 {return}
            if Double(delegate!.xgps160!.speedKph) < 1.5 {return}

            delegate?.coreLocationController?.updateLocation([location],xgps: true)

        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        tableView.reloadData()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func controllerDidConnect(_ notification: Notification) {
        
        let controller = notification.object as! GCController
        print("controller is \(controller)")
        print("game on ")
        print("\(controller.gamepad!.buttonA.isPressed)")

        controller.gamepad?.dpad.up.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed  && value > 0.2 {
                print("dpad.up")
                let userInfo = [
                    "action":"plusOne"]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "PlusOne"), object: nil, userInfo: userInfo)
            }
        }
        
        controller.gamepad?.dpad.down.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed && value > 0.2  {
                print("dpad.up")
                let userInfo = [
                    "action":"minusOne"]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "MinusOne"), object: nil, userInfo: userInfo)
            }
        }
        
        controller.gamepad?.dpad.left.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed  && value > 0.2 {
                print("dpad.left")
                let direction = "reverse"
                let userInfo = [
                    "action":"\(direction)"]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "DirectionChanged"), object: nil, userInfo: userInfo)
                self.directionControl.selectedSegmentIndex = 1
            }
        }
        
        controller.gamepad?.dpad.right.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed && value > 0.2  {
                print("dpad.right")
                let direction = "forward"
                let userInfo = [
                    "action":"\(direction)"]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "DirectionChanged"), object: nil, userInfo: userInfo)
                self.directionControl.selectedSegmentIndex = 0
            }
        }
        
        controller.gamepad?.buttonA.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("buttonA")
                let userInfo = [
                    "action":"reset"]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "Reset"), object: nil, userInfo: userInfo)
            }
        }
        //        controller.gamepad?.buttonB
        controller.gamepad?.buttonB.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("buttonB")
                self.zeroIM(self)
                
//                let userInfo = [
//                    "action":"resetIM"]
//                let zim = String(format: "%.2f", self.splitOM)
//                self.items.insert("ZIM \(zim)", atIndex:0)
//                self.actions.insert("", atIndex:0)
//                self.tableView.reloadData()
//                NSNotificationCenter.defaultCenter().postNotificationName("ResetIM", object: nil, userInfo: userInfo)
            }
        }

        controller.gamepad?.buttonY.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("buttonY")
                let userInfo = [
                    "action":"resetBoth"]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ResetBoth"), object: nil, userInfo: userInfo)
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
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SelectedCountersChanged"), object: nil, userInfo: userInfo)
            }
        }
        controller.gamepad?.rightShoulder.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("rightShoulder")
                self.actions.insert("Split", at: 0)
                self.items.insert(self.milesLbl.text!, at:0)
                self.tableView.reloadData()
            }
        }
    }
    
    // Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
//        print(indexPath.row)
//        print(self.actions.count)
//        print(self.actions)
        cell.textLabel?.text = self.items[(indexPath as NSIndexPath).row]
        cell.detailTextLabel!.text = self.actions[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\((indexPath as NSIndexPath).row)!")

    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            items.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    // End Table
    
    @IBAction func shareBtn(_ sender: UIButton) {
        self.share()
    }
    @IBAction func factorStepper(_ sender: UIStepper) {
        self.factor = sender.value
        self.factorLabel.text = String(format: "%.4f",self.factor)
        let userInfo = [
            "factor":factor]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "FACTOR_CHANGED"), object: nil, userInfo: userInfo)
        self.items.insert(String(format: "%.4f", factor), at:0)
        self.actions.insert("Step Factor", at:0)
        self.tableView.reloadData()
    }
    
    @IBAction func milesKMChanged(_ sender: AnyObject) {
        
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
        NotificationCenter.default.post(name: Notification.Name(rawValue: "MilesKMSelectionChanged"), object: nil, userInfo: userInfo)
    }
    
    func splitFunc(sender:UITapGestureRecognizer) {
        items.insert(String(format: "%.3f", distance), at:0)
        actions.insert("Split OM", at:0)
        self.tableView.reloadData()
    }
    func splitImFunc(sender:UITapGestureRecognizer) {
        items.insert(String(format: "%.3f", distance), at:0)
        actions.insert("Split IM", at:0)
        self.tableView.reloadData()
    }
    
    func split(_ notification:Notification){
        let userInfo = (notification as NSNotification).userInfo
        let m = userInfo!["miles"]!
        items.insert(String(format: "%.3f", m as! Float64), at:0)
        actions.insert("Split", at:0)
        self.tableView.reloadData()
    }
    
    // MARK Actions
    
    
    @IBAction func splitBtn(_ sender: AnyObject) {
        let userInfo = [
            "action":"splitOM"]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "SplitOM"), object: nil, userInfo: userInfo)
    }
    
    @IBAction func selectedCountersChanged(_ sender: AnyObject) {
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
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "SelectedCountersChanged"), object: nil, userInfo: userInfo)
    }
    @IBAction func direction(_ sender: AnyObject) {
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

        NotificationCenter.default.post(name: Notification.Name(rawValue: "DirectionChanged"), object: nil, userInfo: userInfo)

    }
    @IBAction func omStepper(_ sender: UIStepper) {
//        print(sender)
//        print(sender.value)
//        print(oldStepper)
//        print(sender.value < oldStepper)
        if sender.value < oldStepper{
            let userInfo = [
                "action":"minusOne"]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "MinusOne"), object: nil, userInfo: userInfo)

        }
        else{
            let userInfo = [
                "action":"plusOne"]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "PlusOne"), object: nil, userInfo: userInfo)
        }
        oldStepper = sender.value

    }
    
    
    @IBAction func zeroOdo(_ sender: AnyObject) {
        //print("reset Btn pushed")
        let userInfo = [
            "action":"reset"]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Reset"), object: nil, userInfo: userInfo)
    }
    
    @IBAction func zeroIM(_ sender: AnyObject) {
        //print("zeroIM Btn pushed")
        let userInfo = [
            "action":"resetIM"]
        let zim = String(format: "%.2f", self.splitOM)
        items.insert("\(zim)", at:0)
        actions.insert("Zero IM", at:0)
        self.tableView.reloadData()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ResetIM"), object: nil, userInfo: userInfo)
    }
   
    @IBAction func plusMileage(_ sender: AnyObject) {
        //print("+ Btn pushed")
        let userInfo = [
            "action":"plusOne"]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PlusOne"), object: nil, userInfo: userInfo)
    }
    
    @IBAction func minusMileage(_ sender: AnyObject) {
        //print("- Btn pushed")
        let userInfo = [
            "action":"minusOne"]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "MinusOne"), object: nil, userInfo: userInfo)
    }
    
    @IBAction func dialogActions(_ sender: AnyObject) {
        let splitDistance = self.distance

        let alertController = UIAlertController(title: "Actions", message: "Select Action to perform", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            //print(action)
        }
        alertController.addAction(cancelAction)
        
        let clearTable = UIAlertAction(title: "Clear Splits", style: .destructive) {(action) in
            self.items.removeAll()
            self.tableView.reloadData()
        }
        alertController.addAction(clearTable)

        
        let zeroAction = UIAlertAction(title: "Reset Trip Meters", style: .destructive) {(action) in
            let userInfo = [
               "action":"resetBoth"]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ResetBoth"), object: nil, userInfo: userInfo)
        }
        alertController.addAction(zeroAction)
    
        
        let setFactorAction = UIAlertAction(title: "Set Factor", style: .destructive) { (action) in
            //print("Set Factor Btn pushed")
            //Create the AlertController
            let alert: UIAlertController = UIAlertController(title: "Set Factor", message: "Enter Factor", preferredStyle: .alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                //Do some stuff
            }
            alert.addAction(cancelAction)
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action: UIAlertAction!) in
                
                //let textField = alert.textFields![0] as UITextField
                let textField = alert.textFields![0] as UITextField
                self.factorLabel.text = textField.text
                
                textField.keyboardType = UIKeyboardType.numberPad
                let factor = (textField.text! as NSString).floatValue
                //print("save: \(factor)")
                //            self.updateRating(textField.text)
                self.factorStepper.value = Double(factor)
                let userInfo = [
                    "factor":factor]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "FACTOR_CHANGED"), object: nil, userInfo: userInfo)
                self.items.insert(String(format: "%.4f", factor), at:0)
                self.actions.insert("Set Factor", at:0)
                self.tableView.reloadData()
            })
            alert.addAction(saveAction)
            
            //Add a text field
            alert.addTextField { (textField: UITextField!) in
                textField.keyboardType = UIKeyboardType.decimalPad
                textField.text = self.factorLabel.text
            }
            
            //Present the AlertController
            self.present(alert, animated: true, completion: nil)        }
        alertController.addAction(setFactorAction)
        
        let setMileageAction = UIAlertAction(title: "Set Mileage", style: .destructive) { (action) in
//            print("Set Mileage Btn pushed")
            //Create the AlertController
            let alert: UIAlertController = UIAlertController(title: "Set Mileage", message: "Enter Mileage", preferredStyle: .alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                //Do some stuff
            }
            alert.addAction(cancelAction)
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action: UIAlertAction!) in
                
                let textField = alert.textFields![0] as UITextField
                
                textField.keyboardType = UIKeyboardType.numberPad
                let newMileage = (textField.text! as NSString).floatValue
//                print("save: \(newMileage)")
                let userInfo = [
                    "newMileage":newMileage]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SetMileage"), object: nil, userInfo: userInfo)
            })
           alert.addAction(saveAction)
            
            //Add a text field
            alert.addTextField { (textField: UITextField!) in
                textField.keyboardType = UIKeyboardType.decimalPad
                textField.text = ""
            }
        
            //Present the AlertController
            self.present(alert, animated: true, completion: nil)        }
        alertController.addAction(setMileageAction)

//        self.presentViewController(alertController, animated: true) {
//            // ...
//        }
        
        let addNoteAction = UIAlertAction(title: "Add Note", style: .destructive) { (action) in
            //Create the AlertController
            let alert: UIAlertController = UIAlertController(title: "Add Note", message: "Add Note", preferredStyle: .alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                //Do some stuff
            }
            alert.addAction(cancelAction)
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action: UIAlertAction!) in
                
                let textField = alert.textFields![0] as UITextField
//                print(textField.text!)
                self.items.insert("\(String(format: "%.2f", splitDistance))", at:0)
                self.actions.insert("\(textField.text!)", at:0)

                self.tableView.reloadData()
                
            })
            alert.addAction(saveAction)
            
            //Add a text field
            alert.addTextField { (textField: UITextField!) in
                textField.text = ""
            }
            
            //Present the AlertController
            self.present(alert, animated: true, completion: nil)        }
        alertController.addAction(addNoteAction)
        
        self.present(alertController, animated: true) {
            // ...
        }

    }
    


    @IBAction func resetBtn(_ sender: AnyObject) {
        //print("reset Btn pushed")
        let userInfo = [
            "action":"reset"]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Reset"), object: nil, userInfo: userInfo)
    }
    
    @IBAction func setFactorBtn(_ sender: AnyObject) {
        //print("Set Factor Btn pushed")
        //Create the AlertController
        let alert: UIAlertController = UIAlertController(title: "Set Factor", message: "Choose an option!", preferredStyle: .alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff
        }
        alert.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action: UIAlertAction!) in
            
            //let textField = alert.textFields![0] as UITextField
            let textField = alert.textFields![0] as UITextField
            self.factorLabel.text = textField.text

            textField.keyboardType = UIKeyboardType.numberPad
            let factor = (textField.text! as NSString).floatValue
            //print("save: \(factor)")
//            self.updateRating(textField.text)
            let userInfo = [
                "factor":factor]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "FACTOR_CHANGED"), object: nil, userInfo: userInfo)
            
        })
        alert.addAction(saveAction)
        
        //Add a text field
        alert.addTextField { (textField: UITextField!) in
            textField.keyboardType = UIKeyboardType.decimalPad
            textField.text = self.factorLabel.text
        }
        
        //Present the AlertController
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationAvailable(_ notification:Notification) -> Void {
        let userInfo = (notification as NSNotification).userInfo
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
            self.milesLbl.text = (String(format: "%06.3f", m as! Float64))
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
        if (delegate?.xgps160!.isConnected)! == false {
            horrizontalAccuracy.text = String(describing: userInfo!["horizontalAccuracy"]!)
        }

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
        present(activityViewController, animated:true, completion: nil)
        
    }

    
    func stringFromTimeInterval(_ interval:TimeInterval) -> NSString {
        
        let ti = NSInteger(interval)
        
//        let ms = Int((interval % 1) * 1000)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
//        return NSString(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
    }
}

