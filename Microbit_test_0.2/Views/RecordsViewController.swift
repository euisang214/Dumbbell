//
//  RecordsView.swift
//  Microbit_test_0.2
//
//  Created by Ethan Shin on 26/12/2018.
//  Copyright © 2018 Ethan Shin. All rights reserved.
//
import MBCircularProgressBar
import UIKit

protocol RecordsViewControllerDelegate
{
    func updateRecordVC()
}

class RecordsViewController: UIViewController, RecordsViewControllerDelegate
{
    /// MARK: Implementation required by LiveAnalysisViewController
    /// Update the recordVC
    func updateRecordVC()
    {
        updatePB("Average")
    }
    
    /// Updates the PB (Progress Bars) on the desired statistic: either the average or the difference between two most recent sets
    ///
    /// - Parameter statType: The statistic type desired: the average or the difference between two most recent sets
    private func updatePB(_ statType:String)
    {
        if (UserDefaults.standard.object(forKey: "rep"+statType) ?? nil) != nil
        {
            UIView.animate(withDuration: 0.6)
            {
                self.repPB.value = UserDefaults.standard.object(forKey: "rep"+statType) as! CGFloat
            }
            UIView.animate(withDuration: 0.6)
            {
                self.sprPB.value = UserDefaults.standard.object(forKey: "spr"+statType) as! CGFloat
            }
            UIView.animate(withDuration: 0.6)
            {
                self.romPB.value = UserDefaults.standard.object(forKey: "rom"+statType) as! CGFloat
            }
            UIView.animate(withDuration: 0.6)
            {
                self.symmetryPB.value = UserDefaults.standard.object(forKey: "sym"+statType) as! CGFloat
            }
        }
    }
    
    @IBOutlet weak var repPB: MBCircularProgressBarView!
    @IBOutlet weak var sprPB: MBCircularProgressBarView!
    @IBOutlet weak var romPB: MBCircularProgressBarView!
    @IBOutlet weak var symmetryPB: MBCircularProgressBarView!
    
    /// Updates the PB to the desired statistic, based on the segmentControl option selected
    ///
    /// - Parameter sender: UISegmentedControl
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
    
    /// Load the average history by default
    override func viewDidLoad()
    {
        super.viewDidLoad()
        updatePB("Average")
    }
}
