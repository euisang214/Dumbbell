//
//  RepCounter.swift
//  Microbit_test_0.1
//
//  Created by Ethan Shin on 24/12/2018.
//  Copyright © 2018 Peter Wallen. All rights reserved.
//

import Foundation

/// The RepCounter class contains the RangeOfMotion classs for it to function easily when a rep has been conducted
/// This is the easiest implementation since there must be two instances of RepCounter and RangeOfMotion respectively, in pairs for the left and right Microbits, in LiveAnalysisViewController

class RepCounter
{
    /// The RangeOfMotion class
    public var rangeOfMotion:RangeOfMotion?
    
    init()
    {
        rangeOfMotion = RangeOfMotion()
    }
    
    
    /// Processes actions required when half a rep is conducted; aka when the boundary is crossed
    ///
    /// - Parameters:
    ///   - dataHolder: The DataHolder to be processed
    ///   - runCount: The number of times accerlerometer data has been passed to the iOS device
    private func boundaryCrossed(dataHolder:inout DataHolder, runCount:Int)
    {
        dataHolder.crossed += 1
        dataHolder.crossedRunCountLog.append(runCount)
        
        //removing unnecessary history. Most history from before the boundary is crossed again is useless. Removal will improve efficiency
        var simplifiedRaising = dataHolder.crossingZero
        simplifiedRaising.removeSubrange(0...simplifiedRaising.count-1)
        dataHolder.crossingZero = simplifiedRaising
    }
    
    /// The main function for RepCount
    /// Calls boundaryCrossed() and rangeOfMotion functions when necessary
    ///
    /// - Parameters:
    ///   - dataHolder: The DataHolder to be processed
    ///   - runCount: The number of times accerlerometer data has been passed to the iOS device
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
                meetsMinimumAltitudeReq = max(abs(Double(dX[dataHolder.crossedRunCountLog.last!...dX.endIndex-1].max()!)), abs(Double(dX[dataHolder.crossedRunCountLog.last!...dX.endIndex-1].min()!))) > 0.9
            }
            
            if dX[dX.endIndex-2] < dX.last!
            {
                if (dX[dX.endIndex-2]...dX.last!).contains(0) && !recentTwo_dX_are_Zero && meetsMinimumAltitudeReq { crossingZero = true }
            }
            else if (dX.last!...dX[dX.endIndex-2]).contains(0) && !recentTwo_dX_are_Zero && meetsMinimumAltitudeReq { crossingZero = true }
        }

        dataHolder.crossingZero.append(crossingZero)
        
        rangeOfMotion?.updateRecent(x: dataHolder.x.last!)
        
        if crossingZero
        {
            boundaryCrossed(dataHolder: &dataHolder, runCount: runCount)
        }
        
        if dataHolder.crossed%2 == 1
        {
            dataHolder.reps = (dataHolder.crossed+1)/2
        }
            
        //If a rep has been completed
        else if dataHolder.crossed > 0 && crossingZero
        {
            rangeOfMotion?.updateROM(dataHolder: &dataHolder, runCount: runCount)
        }
    }
    
    /// Reset all local variables in this class in preperation for next workout set
    public func resetData() { rangeOfMotion?.resetData() }
}
