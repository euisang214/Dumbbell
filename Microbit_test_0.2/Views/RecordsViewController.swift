//
//  RecordsView.swift
//  Microbit_test_0.2
//
//  Created by Ethan Shin on 26/12/2018.
//  Copyright © 2018 Ethan Shin. All rights reserved.
//
import MBCircularProgressBar
import UIKit

class RecordsViewController: UIViewController
{
    
    // Updates the PB (Progress Bars) on the desired statistic: either the average or the difference between two most recent sets
    private func updatePB(_ statType:String)
    {
        repPB.value = UserDefaults.standard.object(forKey: "rep"+statType) as! CGFloat
        sprPB.value = UserDefaults.standard.object(forKey: "spr"+statType) as! CGFloat
        romPB.value = UserDefaults.standard.object(forKey: "rom"+statType) as! CGFloat
        symmetryPB.value = UserDefaults.standard.object(forKey: "sym"+statType) as! CGFloat
    }
    
    // Functiuon for stats being updated once a new set is completed
    static public func updateRecordVC()
    {
        
    }
    
    @IBOutlet weak var repPB: MBCircularProgressBarView!
    @IBOutlet weak var sprPB: MBCircularProgressBarView!
    @IBOutlet weak var romPB: MBCircularProgressBarView!
    @IBOutlet weak var symmetryPB: MBCircularProgressBarView!
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl)
    {
        switch sender.selectedSegmentIndex
        {
        case 0:
            updatePB("Average")
        case 1:
            updatePB("Diff")
        default:
            break
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        updatePB("Average")
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
