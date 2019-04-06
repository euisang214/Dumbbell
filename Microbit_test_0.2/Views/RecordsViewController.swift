//
//  RecordsView.swift
//  Microbit_test_0.2
//
//  Created by Ethan Shin on 26/12/2018.
//  Copyright © 2018 Ethan Shin. All rights reserved.
//
import MBCircularProgressBar
import UIKit

class RecordsViewController: UIViewController, RecordsViewControllerDelegate
{
    //MARK: Implementation required by LiveAnalysisViewController
    //Allows to be called from LiveAnalysisViewController, updated the moment the workout is stopped
    func updateRecordVC()
    {
        updatePB("Average")
    }
    
    // Updates the PB (Progress Bars) on the desired statistic: either the average or the difference between two most recent sets
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
        /*UserDefaults.standard.set(nil, forKey: "sprAverage")
        UserDefaults.standard.set(nil, forKey: "symAverage")
        UserDefaults.standard.set(nil, forKey: "repAverage")
        UserDefaults.standard.set(nil, forKey: "romAverage")
        
        UserDefaults.standard.set(nil, forKey: "sprDiff")
        UserDefaults.standard.set(nil, forKey: "symDiff")
        UserDefaults.standard.set(nil, forKey: "romDiff")
        UserDefaults.standard.set(nil, forKey: "repDiff")*/
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
