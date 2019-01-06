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

class LiveAnalysis: UIViewController, ComputeDelegate, HomeDelegate {
    
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
    
    var currentProgressBarValues:[Double] = [0,0,0,0]
    
    //to indicate whether the user has stopped the set/the set has been automatically stopped
    var measuring = false

    @IBOutlet weak var blurredView: UIView!
    @IBOutlet weak var repProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var rangeOfMotionProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var secondsPerRepProgressBar: MBCircularProgressBarView!
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
                self.rangeOfMotionProgressBar.value = 0
                self.secondsPerRepProgressBar.value = 0
            }
            
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
            
            countDownLabel.isHidden = false
            for seconds in 0...8
            {
                let when = DispatchTime.now() + (Double(seconds))
                DispatchQueue.main.asyncAfter(deadline: when)
                {
                    self.countDownLabel.text = "\(8-seconds)"
                }
            }
            
            var when = DispatchTime.now() + (9)
            DispatchQueue.main.asyncAfter(deadline: when)
            {
                self.countDownLabel.isHidden = true
                self.view.sendSubviewToBack(self.countDownLabel)
                UIView.animate(withDuration: 0.8)
                {
                    effectView.alpha = 0
                }
            }
            
            when = DispatchTime.now() + (9.85)
            DispatchQueue.main.asyncAfter(deadline: when)
            {
                self.view.sendSubviewToBack(self.blurredView)
                self.measuring = !self.measuring
            }
        }
        else
        {
            prepareForNextSet()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewController.computeDelegate = self
        Home.delegate = self
        
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
        
        rangeOfMotionProgressBar.progressColor = color
        rangeOfMotionProgressBar.value = 0
        rangeOfMotionProgressBar.value = CGFloat(currentProgressBarValues[1])
        
        secondsPerRepProgressBar.progressColor = color
        secondsPerRepProgressBar.value = 0
        secondsPerRepProgressBar.value = CGFloat(currentProgressBarValues[2])
        
        symmetryProgressBar.progressColor = color
        symmetryProgressBar.value = 0
        symmetryProgressBar.value = CGFloat(currentProgressBarValues[3])
        print(currentProgressBarValues)
    }

    private func compute(dataHolder:inout DataHolder?, x:Int16, y:Int16, z:Int16, isRightSide:Bool)
    {
        calculation?.updateDataHolder(dataHolder: &dataHolder!, x: x, y: y, z: z)
        if isRightSide { rightRepCounter?.countRep(dataHolder: &dataHolder!, runCount: rightRunCount) }
        else { leftRepCounter?.countRep(dataHolder: &dataHolder!, runCount: leftRunCount) }
    }
    
    // MARK: Implement required for ComputeDelegate protocol
    public func computeMain(isRightSide:Bool)
    {
        if ViewController.microbitController?.microbit?.isConnected.last! == true && measuring == true
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
                    //labels
                    if rightRunCount%2==0 && rightRunCount>4{ print(((leftData?.dX.last!.description)!) + " " + (rightData?.dX.last!.description)!) }
                    rightRunCount += 1
                    break
                case false:
                    compute(dataHolder: &leftData, x: x, y: y, z: z, isRightSide: isRightSide)
                    //labels
                    leftRunCount += 1
                    break
                }
                
                //updating progress bars
                UIView.animate(withDuration: 0.3)
                {
                    self.currentProgressBarValues[0] = Double(min((self.leftData?.reps)!, (self.rightData?.reps)!))
                    self.repProgressBar.value = CGFloat(self.currentProgressBarValues[0])
                }

                //if leftRepCounter?.rangeOfMotion?.rangeOfMotionSimilarity.count == rightRepCounter?.rangeOfMotion?.rangeOfMotionSimilarity.count
                //{
                    currentProgressBarValues[1] = Double(((leftData?.rangeOfMotion)!+(rightData?.rangeOfMotion)!)/2)
                    UIView.animate(withDuration: 0.4)
                    {
                        self.rangeOfMotionProgressBar.value = CGFloat(self.currentProgressBarValues[1])
                    }
                //}
                
                //if leftData?.crossedRunCountLog.count == rightData?.crossedRunCountLog.count
                //{
                    currentProgressBarValues[2] = ((leftData?.secondsPerRep)!+(rightData?.secondsPerRep)!)/2
                    UIView.animate(withDuration: 0.3)
                    {
                        self.secondsPerRepProgressBar.value = CGFloat(self.currentProgressBarValues[2])
                    }
                //}
                
                //if rightData?.dX != nil && rightRunCount%32==0
                //{
                if leftRunCount%55 == 0
                {
                    UIView.animate(withDuration: 0.3)
                    {
                        self.currentProgressBarValues[3] = Double((self.similarity?.overallSimilarity(leftArray: (self.leftData?.dX)!, rightArray: (self.rightData?.dX)!))!)
                        self.symmetryProgressBar.value = CGFloat(self.currentProgressBarValues[3])
                    }
                }
            }
            //}
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
    }
    
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
