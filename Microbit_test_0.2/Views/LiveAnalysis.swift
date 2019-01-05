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
            measuringStatusUpdateButton.setTitle("Pause", for: .normal)
            measuringStatusUpdateButton.setTitleColor(UIColor.red, for: .normal)
            
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
                UIView.animate(withDuration: 0.4)
                {
                    effectView.alpha = 0
                }
            }
            
            when = DispatchTime.now() + (9.7)
            DispatchQueue.main.asyncAfter(deadline: when)
            {
                self.view.sendSubviewToBack(self.blurredView)
                self.measuring = !self.measuring
            }
        }
        else
        {
            measuring = !measuring
            measuringStatusUpdateButton.setTitle("Start", for: .normal)
            measuringStatusUpdateButton.setTitleColor(UIColor.blue, for: .normal)
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
        
        //timerScreenView.isHidden = true
        //timerScreenView.backgroundColor = UIColor(white: 1, alpha: 0.8)
        //timerScreenView.isOpaque = true
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
            let x = (ViewController.microbitController?.microbitAccelerometer?.getXValue())!
            let y = (ViewController.microbitController?.microbitAccelerometer?.getYValue())!
            let z = (ViewController.microbitController?.microbitAccelerometer?.getZValue())!
            
            switch isRightSide
            {
            case true:
                compute(dataHolder: &rightData, x: x, y: y, z: z, isRightSide: isRightSide)
                //labels
                rightRunCount += 1
                break
            case false:
                compute(dataHolder: &leftData, x: x, y: y, z: z, isRightSide: isRightSide)
                //labels
                leftRunCount += 1
                break
            }
            
            if (detectPause?.isPaused(dataHolderOne: &leftData, dataHolderTwo: &rightData))!
            {
                prepareForNextSet()
            }
            
            //updating progress bars
            UIView.animate(withDuration: 0.3)
            {
                self.repProgressBar.value = CGFloat(min((self.leftData?.reps)!, (self.rightData?.reps)!))
            }
            
            //if leftRepCounter?.rangeOfMotion?.rangeOfMotionSimilarity.count == rightRepCounter?.rangeOfMotion?.rangeOfMotionSimilarity.count
            //{
                let rangeOfMotionValue = ((leftData?.rangeOfMotion)!+(rightData?.rangeOfMotion)!)/2
                UIView.animate(withDuration: 0.4)
                {
                    self.rangeOfMotionProgressBar.value = CGFloat(rangeOfMotionValue)
                }
            //}
            
            //if leftData?.crossedRunCountLog.count == rightData?.crossedRunCountLog.count
            //{
                let secondsPerRep = ((leftData?.secondsPerRep)!+(rightData?.secondsPerRep)!)/2
                UIView.animate(withDuration: 0.3)
                {
                    self.secondsPerRepProgressBar.value = CGFloat(secondsPerRep)
                }
            //}
            
            //if rightData?.dX != nil && rightRunCount%32==0
            //{
                UIView.animate(withDuration: 0.4)
                {
                    print(CGFloat((self.similarity?.liveSimilarity(leftArray: (self.leftData?.dX)!, rightArray: (self.rightData?.dX)!))!))
                    self.symmetryProgressBar.value = CGFloat((self.similarity?.liveSimilarity(leftArray: (self.leftData?.dX)!, rightArray: (self.rightData?.dX)!))!)
                }
            //}
        }
    }
    
    public func prepareForNextSet()
    {
        leftData?.resetData()
        rightData?.resetData()
        leftRepCounter?.resetData()
        rightRepCounter?.resetData()
        leftRunCount = 0
        rightRunCount = 0
        measuring = false
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
