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
    private var prevRaising:Bool?
    
    init(name:String)
    {
        rangeOfMotion = RangeOfMotion()
        speed = Speed()
        self.name = name
    }
    
    private func boundaryCrossed(dataHolder:inout DataHolder, raising:Bool?, name:String, runCount:Int)
    {
        dataHolder.crossed += 1
        prevRaising = raising
        rangeOfMotion?.boundaryCrossed(raising: raising, name: name)
        dataHolder.crossedRunCountLog.append(runCount)
        dataHolder.raising.removeSubrange(0...dataHolder.raising.count-6)
    }
    
    private func addRepIfValid(dataHolder:inout DataHolder, runCount:Int, raising:Bool?)
    {
        let dataHolderRaising = dataHolder.raising
        
        var raisingIsConstant:Bool = true
        
        //checking if actually in motion
        var yesRaiseCount = 0
        for element in dataHolderRaising.suffix(from: dataHolderRaising.count-14)
        {
            if element == raising { yesRaiseCount+=1 }
        }
        if yesRaiseCount>=12 { raisingIsConstant = true }
        else { raisingIsConstant = false }
        
        
       //make the first motion count no matter what
        if ( raisingIsConstant ) && prevRaising == nil // range.contains(boundary)
        {
            boundaryCrossed(dataHolder: &dataHolder, raising: raising, name: name, runCount: runCount )
        }
        
        //ensure reps are only registered for up-down motions, no accidental registers from up-up or down-down
        else if ( raisingIsConstant && (!prevRaising! == raising) )
        {
            boundaryCrossed(dataHolder: &dataHolder, raising: raising, name: name, runCount: runCount)
        }
        
        //updating rep count when crossed is odd; does so to add rep when user pushes/pulles up
        if dataHolder.crossed%2 == 1
        {
            dataHolder.reps = (dataHolder.crossed+1)/2
            speed.secondsPerRep(dataHolder: &dataHolder)
        }
        
        if rangeOfMotion?.recentRange!.count == 2
        {
            rangeOfMotion?.compareToStandard(dataHolder: &dataHolder, runCount: runCount, name:name)
        }
    }
    
    public func countRep(dataHolder: inout DataHolder, runCount:Int)
    {
        let dX = dataHolder.dX
        var raising:Bool?
        
        if dX.count>=10
        {
            if dX.last! > 0 { raising = true }
            else if dX.last! == 0 { raising = nil }
            else { raising = false }
        }
        
        dataHolder.raising.append(raising)
        
        rangeOfMotion?.updateRecent(x: dataHolder.x.last!)

        if dataHolder.raising.count > 14 && raising != nil// 4 seconds delay
        {
            addRepIfValid(dataHolder: &dataHolder, runCount: runCount, raising: raising)
        }
    }
    
    public func resetData()
    {
        rangeOfMotion?.resetData()
        prevRaising = nil
    }
}
