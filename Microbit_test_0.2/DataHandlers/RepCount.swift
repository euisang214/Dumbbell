//
//  RepCounter.swift
//  Microbit_test_0.1
//
//  Created by Ethan Shin on 24/12/2018.
//  Copyright © 2018 Peter Wallen. All rights reserved.
//

import Foundation

class RepCounter
{
    public var rangeOfMotion:RangeOfMotion?
    public var speed:Speed
    
    private var name:String
    
    init(name:String)
    {
        rangeOfMotion = RangeOfMotion()
        speed = Speed()
        self.name = name
    }
    
    private func boundaryCrossed(dataHolder:inout DataHolder, crossedZero:Bool?, name:String, runCount:Int)
    {
        dataHolder.crossed += 1
        dataHolder.crossedRunCountLog.append(runCount)
        
        //removing unnecessary history. Most history from before the boundary is crossed again is useless. Removal will improve efficiency
        var simplifiedRaising = dataHolder.crossingZero
        simplifiedRaising.removeSubrange(0...simplifiedRaising.count-1)
        dataHolder.crossingZero = simplifiedRaising
    }
    
    public func countRep(dataHolder: inout DataHolder, runCount:Int)
    {
        let dX = dataHolder.dX
        var crossingZero:Bool = false
        var meetsMinimumAltitudeReq:Bool = true
        
        if dX.count >= 2
        {
            let recentTwo_dX_are_Zero = dX[dX.endIndex-2] == 0.0 && dX.last! == 0.0
            
            if dataHolder.crossedRunCountLog.count >= 1
            {
                meetsMinimumAltitudeReq = max(abs(Double(dataHolder.dX[dataHolder.crossedRunCountLog.last!...dataHolder.dX.endIndex-1].max()!)), abs(Double(dataHolder.dX[dataHolder.crossedRunCountLog.last!...dataHolder.dX.endIndex-1].min()!))) > 0.9
            }
            
            if dX[dX.endIndex-2] < dX.last!
            {
                if (dX[dX.endIndex-2]...dX.last!).contains(0) && !recentTwo_dX_are_Zero && meetsMinimumAltitudeReq { crossingZero = true }
            }
            else if (dX.last!...dX[dX.endIndex-2]).contains(0) && !recentTwo_dX_are_Zero && meetsMinimumAltitudeReq { crossingZero = true }
        }
        
        /*if crossingZero && dataHolder.crossedRunCountLog.count >= 1
        {
            print()
            print("altitude: \(max(abs(Double(dataHolder.dX[dataHolder.crossedRunCountLog.last!...dataHolder.dX.endIndex-1].max()!)), abs(Double(dataHolder.dX[dataHolder.crossedRunCountLog.last!...dataHolder.dX.endIndex-1].min()!))))")
            print("meetsMinimumAltitudeReq: \(meetsMinimumAltitudeReq)")
            print()
        }*/


        dataHolder.crossingZero.append(crossingZero)
        
        rangeOfMotion?.updateRecent(x: dataHolder.x.last!)
        
        if crossingZero
        {
            boundaryCrossed(dataHolder: &dataHolder, crossedZero: crossingZero, name: name, runCount: runCount)
        }
        
        if dataHolder.crossed%2 == 1
        {
            dataHolder.reps = (dataHolder.crossed+1)/2
            speed.secondsPerRep(dataHolder: &dataHolder)
        }
            
            //If a rep has been completed
        else if dataHolder.crossed > 0 && crossingZero
        {
            rangeOfMotion?.updateRangeOfMotion(dataHolder: &dataHolder, runCount: runCount, name:name)
        }
    }
    
    public func resetData() { rangeOfMotion?.resetData() }
}
