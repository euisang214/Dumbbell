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

class LiveAnalysis: UIViewController, ComputeDelegate {
    
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
    
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var repLabel: UILabel!
    @IBOutlet weak var threeDLabel: UILabel!
    @IBOutlet weak var repProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var rangeOfMotionProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var secondsPerRepProgressBar: MBCircularProgressBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewController.computeDelegate = self
        
        leftRunCount = 0
        rightRunCount = 0
        
        calculation = Calculation()
        similarity = Similarity()
        detectPause = DetectPause()
        rightData = DataHolder()
        leftData = DataHolder()
        leftRepCounter = RepCounter(name:"Left")
        rightRepCounter = RepCounter(name:"Right")
        
    }


    private func compute(dataHolder:inout DataHolder?, x:Int16, y:Int16, z:Int16, isRightSide:Bool)
    {
        calculation?.updateDataHolder(dataHolder: &dataHolder!, x: x, y: y, z: z)
        if isRightSide { rightRepCounter?.countRep(dataHolder: &dataHolder!, runCount: rightRunCount) }
        else { leftRepCounter?.countRep(dataHolder: &dataHolder!, runCount: leftRunCount) }
    }
    
    @IBOutlet weak var leftRep: UILabel!
    @IBOutlet weak var leftX: UILabel!
    @IBOutlet weak var rightRep: UILabel!
    @IBOutlet weak var rightX: UILabel!
    
    public func computeMain(isRightSide:Bool)
    {
        if ViewController.microbitController?.microbit?.isConnected.last! == true
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
                LiveAnalysis.liveAnalysisDelegate?.disconnectMicrobits()
            }
            else
            {
                leftRep.text = leftData?.reps.description
                rightRep.text = rightData?.reps.description
                if isRightSide { rightX.text = rightData!.x.last!.description }
                else { leftX.text = leftData!.x.last!.description }
            }
            
            //updating progress bars
            repProgressBar.value = CGFloat(min((leftData?.reps)!, (rightData?.reps)!))
            
            if leftRepCounter?.rangeOfMotion?.rangeOfMotionSimilarity.count == rightRepCounter?.rangeOfMotion?.rangeOfMotionSimilarity.count
            {
                let rangeOfMotionValue = ((leftData?.rangeOfMotion)!+(rightData?.rangeOfMotion)!)/2
                rangeOfMotionProgressBar.value = CGFloat(rangeOfMotionValue)
            }
            
            if leftData?.crossedRunCountLog.count == rightData?.crossedRunCountLog.count
            {
                let secondsPerRep = ((leftData?.secondsPerRep)!+(rightData?.secondsPerRep)!)/2
                secondsPerRepProgressBar.value = CGFloat(secondsPerRep)
            }
            
            
            //similarity?.liveSimilarity(leftArray: <#T##[Int16]#>, rightArray: <#T##[Int16]#>)
            // similarity?.overallSimilarity(leftArray: <#T##[Int16]#>, rightArray: <#T##[Int16]#>)
        }
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
