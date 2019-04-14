//
//  LiveAnalysis.swift
//  Microbit_test_0.2
//
//  Created by Ethan Shin on 26/12/2018.
//  Copyright © 2018 Ethan Shin. All rights reserved.
//

import UIKit
import MBCircularProgressBar

/// Delegate to disconnect MircoBits
/// Inherited in HomeViewController
protocol LiveAnalysisDelegate
{
    func disconnectMicrobits()
}

/// Class that controls the live processing view
class LiveAnalysisViewController: UIViewController, ComputeDelegate, HomeDelegate {
    
    static var liveAnalysisDelegate:LiveAnalysisDelegate?
    public var recordsViewControllerDelegate:RecordsViewControllerDelegate?
    
    var calculation:Calculation?
    
    var similarity:Similarity?
    
    var detectPause:DetectPause?
    
    var speech:Speech?
    
    var leftData:DataHolder?
    var rightData:DataHolder?
    
    var leftRepCounter:RepCounter?
    var rightRepCounter:RepCounter?
    
    /// The number of times accerlerometer data from the LEFT MICROBIT has been passed to the iOS device
    var leftRunCount:Int = 0
    /// The number of times accerlerometer data from the RIGHT MICROBIT has been passed to the iOS device
    var rightRunCount:Int  = 0
    
    /// Stores the most recent number of reps, range of motion, seconds per rep, and similarity in this specific order.
    /// Necessary because DataHolder only contains average for one side, while livePBValues account for both sides
    var livePBValues:[Double] = [0,0,0,0]
    /// Stores the average of each respective statistic to simplify process of saving to local storage.
    /// Necessary because DataHolder only contains average for one side, while livePBValues account for both sides
    var averagePBValues:[Double] = [0,0,0,0]
    /// Previous averagePBValues
    var previousAveragePBValues:[Double] = [0,0,0,0]
    
    /// Indicates whether the (user has stopped the set) / (set has been automatically stopped)
    var measuring = false
    
    @IBOutlet weak var blurredView: UIView!
    @IBOutlet weak var repProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var romProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var sprProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var symmetryProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var countDownLabel: UILabel!
    
    @IBOutlet weak var measuringStatusUpdateButton: UIButton!
    
    /// Action when the start/stop button is pressed
    ///
    /// - Parameter sender: sender
    @IBAction func measuringStatusUpdateButtonPressed(_ sender: Any)
    {
        if !measuring
        {
            measuringStatusUpdateButton.setTitle("Stop", for: .normal)
            measuringStatusUpdateButton.setTitleColor(UIColor.red, for: .normal)
            
            setProgressBarColors(color: UIColor.blue)
            
            UIView.animate(withDuration: 0.3)
            {
                self.repProgressBar.value = 0
                self.symmetryProgressBar.value = 0
                self.romProgressBar.value = 0
                self.sprProgressBar.value = 0
            }
            arrangeTimer(seconds: 2)
        }
        else
        {
            prepareForNextSet()
        }
    }
    
    /// Initialisation
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        ViewController.computeDelegate = self
        HomeViewController.delegate = self
        
        leftRunCount = 0
        rightRunCount = 0
        
        calculation = Calculation()
        similarity = Similarity()
        detectPause = DetectPause()
        rightData = DataHolder()
        leftData = DataHolder()
        leftRepCounter = RepCounter()
        rightRepCounter = RepCounter()
        
        measuringStatusUpdateButton.setTitleColor(UIColor.gray, for: .disabled)
        measuringStatusUpdateButton.isEnabled = false
        speech = Speech()
    }

    /// Instantly change all progress bars to given color
    ///
    /// - Parameter color: The color to which the progress bars will be changed
    private func setProgressBarColors(color:UIColor)
    {
        repProgressBar.progressColor = color
        repProgressBar.value = 0
        repProgressBar.value = CGFloat(livePBValues[0])
        
        romProgressBar.progressColor = color
        romProgressBar.value = 0
        romProgressBar.value = CGFloat(livePBValues[1])
        
        sprProgressBar.progressColor = color
        sprProgressBar.value = 0
        sprProgressBar.value = CGFloat(livePBValues[2])
        
        symmetryProgressBar.progressColor = color
        symmetryProgressBar.value = 0
        symmetryProgressBar.value = CGFloat(livePBValues[3])
    }
    
    /// Arranges the animation and countdown of the timer.
    ///
    /// - Parameter seconds: Number of seconds the countdown will last
    private func arrangeTimer(seconds:Int)
    {
        //Setup the blur effect view to be overlayed over the screen
        let blurEffect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = self.view.frame
        blurredView.addSubview(effectView)
        effectView.alpha = 0
        UIView.setAnimationCurve(.easeInOut)
        self.view.bringSubviewToFront(blurredView)
        self.view.bringSubviewToFront(countDownLabel)
        UIView.animate(withDuration: 0.8)
        {
            effectView.alpha = 0.8
        }
        
        //Countdown mechanism
        countDownLabel.isHidden = false
        for secondsLeft in 0...seconds
        {
            let when = DispatchTime.now() + (Double(secondsLeft))
            DispatchQueue.main.asyncAfter(deadline: when)
            {
                self.countDownLabel.text = "\(seconds-secondsLeft)"
            }
        }
        
        //closing the blur effect view and timer
        let timerEndTime:Double = Double(seconds+1)
        var when = DispatchTime.now() + timerEndTime
        DispatchQueue.main.asyncAfter(deadline: when)
        {
            self.countDownLabel.isHidden = true
            self.view.sendSubviewToBack(self.countDownLabel)
            UIView.animate(withDuration: 0.8)
            {
                effectView.alpha = 0
            }
        }
        
        when = DispatchTime.now() + (timerEndTime+0.05)
        DispatchQueue.main.asyncAfter(deadline: when)
        {
            self.view.sendSubviewToBack(self.blurredView)
            self.measuring = !self.measuring
        }
    }

    /// Updates SPR, ROM, and Speed if applicable for given DataHolder
    ///
    /// - Parameters:
    ///   - dataHolder: The DataHolder to be referenced from
    ///   - x: The x acceleration
    ///   - y: The y acceleration
    ///   - z: The z acceleration
    ///   - isRightSide: Whether the Microbit is on the left/right arm
    private func compute(dataHolder:inout DataHolder?, x:Int16, y:Int16, z:Int16, isRightSide:Bool)
    {
        calculation?.updateDataHolder(dataHolder: &dataHolder!, x: x, y: y, z: z)
        if isRightSide { rightRepCounter?.countRep(dataHolder: &dataHolder!, runCount: rightRunCount) }
        else { leftRepCounter?.countRep(dataHolder: &dataHolder!, runCount: leftRunCount) }
    }

    /// Saves average of the given statistic into local storage
    ///
    /// - Parameters:
    ///   - stat: The statistic to be saved
    ///   - LPBVIndex: livePBValue's index for this statistic
    private func saveLocal_Average(_ stat:String, LPBVIndex:Int)
    {
        if (UserDefaults.standard.object(forKey: stat+"Average") ?? nil) != nil
        {
            let statistic = (UserDefaults.standard.object(forKey: stat+"Average") as! Double + averagePBValues[LPBVIndex]) / 2.0
            UserDefaults.standard.set(statistic, forKey: stat+"Average")
        }
        else
        {
            UserDefaults.standard.set(averagePBValues[LPBVIndex], forKey: stat+"Average")
        }
    }

    /// Saves most recent difference of the given statistic into local storage
    ///
    /// - Parameters:
    ///   - stat: The statistic to be saved
    ///   - LPBVIndex: livePBValues's index for this statistic
    private func saveLocal_Diff(_ stat:String, LPBVIndex:Int)
    {
        if (UserDefaults.standard.object(forKey: stat+"Diff") ?? nil) != nil
        {
            let statDiff = averagePBValues[LPBVIndex] - (UserDefaults.standard.object(forKey: stat+"Diff") as! Double)
            UserDefaults.standard.set(statDiff, forKey: stat+"Diff")
        }
        else
        {
            //print(String(LPBVIndex) + " " + String(averagePBValues[LPBVIndex]))
            UserDefaults.standard.set(averagePBValues[LPBVIndex], forKey: stat+"Diff")
        }
    }

    /// Updates the average value of given statistic to respective index in averagePBValues
    /// Also updates previousAveragePBValues
    /// Also calls updateSpeech_averageLogs to update Speech's local variable averageLogs
    ///
    /// - Parameter index: averagePBValues's index for this statistic
    private func updateAveragePBValues(index:Int)
    {
        if averagePBValues[index] == 0 { averagePBValues[index] = livePBValues[index] }
        else { averagePBValues[index] = (averagePBValues[index]+livePBValues[index])/2 }
        callForSpeech(index: index, value: averagePBValues[index])
        previousAveragePBValues[index] = averagePBValues[index]
    }
    
    
    /// Updates Speech's local variable averageLogs
    ///
    /// - Parameters:
    ///   - index: averagePBValues's index for this statistic
    ///   - value: Value to be appended at this index
    private func callForSpeech(index:Int, value:Double)
    {
        //print("\(previousAveragePBValues[index])  \(averagePBValues[index])")
        if index > 0 && index < 3 && previousAveragePBValues[index] != averagePBValues[index]
        {
            speech?.appendToAverageLogs(index: index, value)
            speech?.provideFeedback_Main(index: index, leftData: leftData!, rightData: rightData!)
        }
    }
    
    /// MARK: Implement required for ComputeDelegate protocol
    /// The main computation and UI refresher
    ///
    /// - Parameter isRightSide: Whether the Microbit is on the left/right arm
    public func computeMain(isRightSide:Bool)
    {
        //print(isRightSide)
        /*print("\(isRightSide) \(leftRunCount) \(rightRunCount)")
        print("\(isRightSide && rightRunCount <= leftRunCount)" +  " \(!isRightSide && leftRunCount <= rightRunCount)")*/
        if ViewController.microbitController?.microbit?.isConnected.last! == true && measuring == true && ( (isRightSide && rightRunCount <= leftRunCount) || (!isRightSide && leftRunCount <= rightRunCount) )
        {
            if (detectPause?.isPaused(dataHolderOne: &leftData, dataHolderTwo: &rightData, runCount:leftRunCount))!
            {
                prepareForNextSet()
            }
            else
            {
                let x = (ViewController.microbitController?.microbitAccelerometer?.getXValue())!
                let y = (ViewController.microbitController?.microbitAccelerometer?.getYValue())!
                let z = (ViewController.microbitController?.microbitAccelerometer?.getZValue())!
                
                switch isRightSide
                {
                case true:
                    compute(dataHolder: &rightData, x: x, y: y, z: z, isRightSide: isRightSide)
                    rightRunCount += 1
                    break
                case false:
                    compute(dataHolder: &leftData, x: x, y: y, z: z, isRightSide: isRightSide)
                    //labels
                    leftRunCount += 1
                    break
                }
                
                //updating repProgressBar
                livePBValues[0] = Double(min((leftData?.reps)!, (rightData?.reps)!))
                updateAveragePBValues(index: 0)
                
                UIView.animate(withDuration: 0.3)
                {
                    self.repProgressBar.value = CGFloat(self.livePBValues[0])
                }
                
                //updating romProgressBar
                livePBValues[1] = Double(((leftData?.rom)!+(rightData?.rom)!)/2)
                updateAveragePBValues(index: 1)
                UIView.animate(withDuration: 0.4)
                {
                    self.romProgressBar.value = CGFloat(self.livePBValues[1])
                }
                
                //updating sprProgressBar
                livePBValues[2] = ((leftData?.spr)!+(rightData?.spr)!)/2
                updateAveragePBValues(index: 2)
                UIView.animate(withDuration: 0.3)
                {
                    self.sprProgressBar.value = CGFloat(self.livePBValues[2])
                }
                
                //updating symmetryProgressBar
                if leftRunCount%55 == 0
                {
                    UIView.animate(withDuration: 0.3)
                    {
                        let tempSimil = Double((self.similarity?.overallSimilarity(leftArray: (self.leftData?.dX)!, rightArray: (self.rightData?.dX)!))!)
                        if tempSimil != -1
                        {
                            self.livePBValues[3] = tempSimil
                            self.updateAveragePBValues(index: 3)
                            self.symmetryProgressBar.value = CGFloat(self.livePBValues[3])
                        }
                    }
                }
            }
        }
    }
    
    /// MARK: Implementation required for HomeDelegate protocol
    ///
    /// Reset all local variables in this class in preperation for next workout set
    public func prepareForNextSet()
    {
        measuring = false
        
        let when = DispatchTime.now() + (0.35)
        DispatchQueue.main.asyncAfter(deadline: when)
        {
            self.leftData?.resetData()
            self.rightData?.resetData()
            self.leftRepCounter?.resetData()
            self.rightRepCounter?.resetData()
            self.leftRunCount = 0
            self.rightRunCount = 0
        }
        
        measuringStatusUpdateButton.setTitleColor(UIColor.blue, for: .normal)
        measuringStatusUpdateButton.setTitle("Start", for: .normal)
        
        setProgressBarColors(color: UIColor.orange)
        
        //Saving to long term data for performance comparisons once a set is completed
        //Keys: repAverage, symAverage, romAverage, sprAverage, repDiff, symDiff, romDiff, sprDiff
        
        // Updating averages
        saveLocal_Average("rep", LPBVIndex: 0)
        saveLocal_Average("rom", LPBVIndex: 1)
        saveLocal_Average("spr", LPBVIndex: 2)
        saveLocal_Average("sym", LPBVIndex: 3)
        
        //Updating most recent performance differences
        saveLocal_Diff("rep", LPBVIndex: 0)
        saveLocal_Diff("rom", LPBVIndex: 1)
        saveLocal_Diff("spr", LPBVIndex: 2)
        saveLocal_Diff("sym", LPBVIndex: 3)
        
        recordsViewControllerDelegate?.updateRecordVC()
    }
    
    /// MARK: Implementation required for HomeDelegate protocol
    ///
    /// Change the status of the measuringStatusUpdateButton
    /// - Parameter bool: The state of the measuringStatusUpdateButton
    public func changeMeasuringStatusUpdateButtonStatus(_ bool:Bool)
    {
        measuringStatusUpdateButton.isEnabled = bool
    }
}
