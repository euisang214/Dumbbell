//
//  LiveAnalysis.swift
//  Microbit_test_0.2
//
//  Created by Ethan Shin on 26/12/2018.
//  Copyright © 2018 Ethan Shin. All rights reserved.
//

import UIKit
import MBCircularProgressBar

protocol LiveAnalysisDelegate
{
    func disconnectMicrobits()
}

class LiveAnalysisViewController: UIViewController, ComputeDelegate, HomeDelegate {
    
    static var liveAnalysisDelegate:LiveAnalysisDelegate?

    var calculation:Calculation?
    
    var similarity:Similarity?
    
    var detectPause:DetectPause?
    
    var leftData:DataHolder?
    var rightData:DataHolder?
    
    var leftRepCounter:RepCounter?
    var rightRepCounter:RepCounter?
    
    var leftRunCount:Int = 0
    var rightRunCount:Int  = 0
    
    //Stores the most recent number of reps, range of motion, seconds per rep, and similarity in this specific order
    var currentProgressBarValues:[Double] = [0,0,0,0]
    
    //to indicate whether the user has stopped the set/the set has been automatically stopped
    var measuring = false

    @IBOutlet weak var blurredView: UIView!
    @IBOutlet weak var repProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var romProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var sprProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var symmetryProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var countDownLabel: UILabel!
    
    @IBOutlet weak var measuringStatusUpdateButton: UIButton!
    
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
    
    override func viewDidLoad() {
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
        leftRepCounter = RepCounter(name:"Left")
        rightRepCounter = RepCounter(name:"Right")
        
        measuringStatusUpdateButton.setTitleColor(UIColor.gray, for: .disabled)
        measuringStatusUpdateButton.isEnabled = false
    }

    private func setProgressBarColors(color:UIColor)
    {
        repProgressBar.progressColor = color
        repProgressBar.value = 0
        repProgressBar.value = CGFloat(currentProgressBarValues[0])
        
        romProgressBar.progressColor = color
        romProgressBar.value = 0
        romProgressBar.value = CGFloat(currentProgressBarValues[1])
        
        sprProgressBar.progressColor = color
        sprProgressBar.value = 0
        sprProgressBar.value = CGFloat(currentProgressBarValues[2])
        
        symmetryProgressBar.progressColor = color
        symmetryProgressBar.value = 0
        symmetryProgressBar.value = CGFloat(currentProgressBarValues[3])
    }
    
    //Arranges the animation and countdown of the timer.
    //Seconds variable: number of seconds the countdown will last
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

    //Updating DataHolder and running .countRep (all core functions)
    private func compute(dataHolder:inout DataHolder?, x:Int16, y:Int16, z:Int16, isRightSide:Bool)
    {
        calculation?.updateDataHolder(dataHolder: &dataHolder!, x: x, y: y, z: z)
        if isRightSide { rightRepCounter?.countRep(dataHolder: &dataHolder!, runCount: rightRunCount) }
        else { leftRepCounter?.countRep(dataHolder: &dataHolder!, runCount: leftRunCount) }
    }
    
    // Function saves average of the given statistic into local storage
    // stat: the statistic to be saved
    // CPBVIndex: currentProgressBarValueIndex
    private func saveLocal_Average(_ stat:String, CPBVIndex:Int)
    {
        let statistic = (UserDefaults.standard.object(forKey: stat+"Average") as! Double + currentProgressBarValues[CPBVIndex]) / 2.0
        UserDefaults.standard.set(statistic, forKey: stat+"Average")
    }
    
    // Function saves most recent difference of the given statistic into local storage
    // stat: the statistic to be saved
    // CPBVIndex: currentProgressBarValueIndex
    private func saveLocal_Diff(_ stat:String, CPBVIndex:Int)
    {
        let statDiff = currentProgressBarValues[CPBVIndex] - (UserDefaults.standard.object(forKey: stat+"Diff") as! Double)
        UserDefaults.standard.set(statDiff, forKey: stat+"Diff")
    }
    
    // MARK: Implement required for ComputeDelegate protocol
    public func computeMain(isRightSide:Bool)
    {
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
                
                //updating progress bars
                
                currentProgressBarValues[0] = Double(min((leftData?.reps)!, (rightData?.reps)!))
                UIView.animate(withDuration: 0.3)
                {
                    self.repProgressBar.value = CGFloat(self.currentProgressBarValues[0])
                }
                
                currentProgressBarValues[1] = Double(((leftData?.rangeOfMotion)!+(rightData?.rangeOfMotion)!)/2)
                UIView.animate(withDuration: 0.4)
                {
                    self.romProgressBar.value = CGFloat(self.currentProgressBarValues[1])
                }

                currentProgressBarValues[2] = ((leftData?.secondsPerRep)!+(rightData?.secondsPerRep)!)/2
                UIView.animate(withDuration: 0.3)
                {
                    self.sprProgressBar.value = CGFloat(self.currentProgressBarValues[2])
                }

                if leftRunCount%55 == 0
                {
                    UIView.animate(withDuration: 0.3)
                    {
                        let tempSimil = Double((self.similarity?.overallSimilarity(leftArray: (self.leftData?.dX)!, rightArray: (self.rightData?.dX)!))!)
                        //print(tempSimil)
                        if tempSimil != -1
                        {
                            self.currentProgressBarValues[3] = tempSimil
                            self.symmetryProgressBar.value = CGFloat(self.currentProgressBarValues[3])
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Implementation required for HomeDelegate protocol
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
        //Keys: repAverage, similAverage, romAverage, sprAverage, repDiff, similDiff, romDiff, sprDiff
        
        // if data is saved from previous sessions
        if UserDefaults.standard.object(forKey: "repAverage") as? Double != nil
        {
            // Updating averages
            saveLocal_Average("rep", CPBVIndex: 0)
            saveLocal_Average("sym", CPBVIndex: 1)
            saveLocal_Average("rom", CPBVIndex: 2)
            saveLocal_Average("spr", CPBVIndex: 3)
            
            //Updating most recent performance differences
            saveLocal_Diff("rep", CPBVIndex: 0)
            saveLocal_Diff("sym", CPBVIndex: 1)
            saveLocal_Diff("rom", CPBVIndex: 2)
            saveLocal_Diff("spr", CPBVIndex: 3)
        }
    }
    
    // MARK: Implementation required for HomeDelegate protocol
    public func changeMeasuringStatusUpdateButtonStatus(_ bool:Bool)
    {
        measuringStatusUpdateButton.isEnabled = bool
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
