//
//  RangeOfMotion.swift
//  Microbit_test_0.2
//
//  Created by Ethan Shin on 29/12/2018.
//  Copyright © 2018 Ethan Shin. All rights reserved.
//

import Foundation

//RangeOfMotion will be instantiated in the RepCount class to easily identify when dataHolder.crossed increases
//Since RepCount accounts for a single microbit, RangeOfMotion only needs to account for one microbit
class RangeOfMotion
{
    //Stores the acceleration between boundary crosses
    public var recentReps:[Double]
    
    //Stores the default range of motion: based on the first rep
    private var standardDifference:Double?
    
    public var romLog:[Int16]
    
    init()
    {
        recentReps = []
        standardDifference = nil
        romLog = []
    }
    
    public func updateRecent(x:Double) { recentReps.append(x) }

    //called when a rep is completed; when dataHolder.crossed%2==0
    public func updateRangeOfMotion(dataHolder:inout DataHolder, runCount:Int, name:String)
    {
        //a variable that will contain the most recent range travelled, in double; aka the difference between the greatest and smallest accelerometer values
        let range:Double = abs( Double(recentReps.max()! - recentReps.min()!) )
       
        print()
        print()
        print("Range : \(range)")
        print("recentReps.max = \(recentReps.max()!)")
        print("recentReps.min = \(recentReps.min()!)")
        print("recentReps.count = \(recentReps.count)")
        print("runCount = \(runCount)")
        print()
        print()
 
        if standardDifference != nil
        {
            if range < standardDifference! { romLog.append(Int16 (range/standardDifference!*Double(100) )) }
            //if most recent range travelled is greater than the standard, this range becomes the standard
            else
            {
                standardDifference = range
                romLog.append(100)
            }
            //getting percentage
            dataHolder.rom = romLog.last!
            if dataHolder.romAverage == 0 { dataHolder.romAverage = dataHolder.rom }
            else { dataHolder.romAverage = (dataHolder.rom+dataHolder.romAverage)/2 }
        }
        else
        {
            //print("Standard difference calculation for \(name): " + recentRange![0].description + " " + recentRange![1].description)
            standardDifference = range
            dataHolder.rom = 100
        }
        
        recentReps.removeAll()
    }
    
    public func resetData()
    {
        recentReps.removeAll()
        standardDifference = nil
        romLog.removeAll()
    }
}

