//
//  ModalOutTimeViewController.swift
//  SwiftOdo
//
//  Created by Clarence Westberg on 11/10/15.
//  Copyright © 2015 Clarence Westberg. All rights reserved.
//

import UIKit

class ModalOutTimeViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func incrementUnits(sender: AnyObject) {
    }
    
    @IBAction func setTime(sender: AnyObject) {dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
