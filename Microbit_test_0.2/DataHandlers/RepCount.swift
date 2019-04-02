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
        
        if dX.count >= 2
        {
            let recentTwo_dX_are_Zero = dX[dX.endIndex-2] == 0.0 && dX.last! == 0.0
            var meetsMinimumAltitudeReq:Bool = true
            
            if dataHolder.crossedRunCountLog.count >= 1
            {
                if Double(dataHolder.dX[dataHolder.crossedRunCountLog.last!...dataHolder.dX.endIndex-1].max()!).magnitude > Double(dataHolder.dX[dataHolder.crossedRunCountLog.last!...dataHolder.dX.endIndex-1].min()!).magnitude
                {
                    
                }
                
                
                meetsMinimumAltitudeReq = max(abs(Double(dataHolder.dX[dataHolder.crossedRunCountLog.last!...dataHolder.dX.endIndex-1].max()!)), abs(Double(dataHolder.dX[dataHolder.crossedRunCountLog.last!...dataHolder.dX.endIndex-1].max()!))) > 1
                /*print()
                print("altitude: \(max(abs(Double(dataHolder.dX[dataHolder.crossedRunCountLog.last!...dataHolder.dX.endIndex-1].max()!)), abs(Double(dataHolder.dX[dataHolder.crossedRunCountLog.last!...dataHolder.dX.endIndex-1].min()!))))")
                print("meetsMinimumAltitudeReq: \(meetsMinimumAltitudeReq)")
                print()*/
            }
            
            if dX[dX.endIndex-2] < dX.last!
            {
                if (dX[dX.endIndex-2]...dX.last!).contains(0) && !recentTwo_dX_are_Zero { crossingZero = true }
            }
            else if (dX.last!...dX[dX.endIndex-2]).contains(0) && !recentTwo_dX_are_Zero { crossingZero = true }
        }
        
        /*
        //make class local variable of what the previous direction was: e.i var prevDDX:Int
        // purpose of prevDDXDir is to see whether the direction, + or -, has changed in ddX
        var prevDDX_isPositive:Bool?
        var raising:Bool // replacing name for crossingZero; their functions should be identical
        if dX.count >= 2
        {
            let ddX = dX.last! - dX[dX.endIndex-2]
            
            // accounting for when the dX >= 2 for the first time
            if prevDDX_isPositive != nil
            {
                // if the change in ddX is less than 4; and the signs of prevDDX and ddX are opposite
                if abs (ddX) < 4 && ( (ddX > 0 && !prevDDX_isPositive!) || (ddX < 0 && prevDDX_isPositive!) )
                {
                    raising = true
                }
                else { raising = false }
            }
            prevDDX_isPositive = ddX > 0
        }
        else
        {
            raising = false
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
        else if dataHolder.crossed > 0
        {
            rangeOfMotion?.updateRangeOfMotion(dataHolder: &dataHolder, runCount: runCount, name:name)
        }
    }
    
    public func resetData() { rangeOfMotion?.resetData() }
}
