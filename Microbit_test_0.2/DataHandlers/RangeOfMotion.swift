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
    public var recentReps:[Int16]?
    
    public var recentRange:[Int16]?
    //Stores the default range of motion: based on the first rep
    private var standardDifference:Double?
    
    public var rangeOfMotionRecord:[Int16]
    
    init()
    {
        recentReps = []
        recentRange = []
        standardDifference = nil
        rangeOfMotionRecord = []
    }
    
    public func updateRecent(x:Int16) { recentReps?.append(x) }
    
    //Called when half a rep is executed
    public func boundaryCrossed(raising:Bool?, name:String)
    {
        if raising == true { recentRange?.append((recentReps?.min())!) }
        else { recentRange?.append((recentReps?.max())!) }
       // print(name + " " + (recentRange?.count.description)!)
    }

    //called when a rep is completed; when dataHolder.crossed%2==0
    public func updateRangeOfMotion(dataHolder:inout DataHolder, runCount:Int, name:String)
    {
        //a variable that will contain the most recent range travelled 
        var recentDifference:Double
        
        if standardDifference != nil
        {
            recentDifference = Double( abs(Int32(recentRange![0]-recentRange![1])) )
            if recentDifference < standardDifference! { rangeOfMotionRecord.append(Int16 (recentDifference/standardDifference!*Double(100) )) }
            //if most recent range travelled is greater than the standard, this range becomes the standard
            else
            {
                standardDifference = recentDifference
                rangeOfMotionRecord.append(100)
            }
            //getting percentage
            dataHolder.rangeOfMotion = rangeOfMotionRecord.last!
        }
        else
        {
            //print("Standard difference calculation for \(name): " + recentRange![0].description + " " + recentRange![1].description)
            standardDifference = Double( abs(Int32(recentRange![0]-recentRange![1])) )*0.98
            dataHolder.rangeOfMotion = 100
        }
        
        if dataHolder.rangeOfMotion > 100 {
            (name + " " + recentRange![0].description + " " + recentRange![1].description + "  " + standardDifference!.description) }

        recentRange?.removeAll()
        recentReps?.removeAll()
    }
    
    public func resetData()
    {
        recentReps?.removeAll()
        recentRange?.removeAll()
        standardDifference = nil
        rangeOfMotionRecord.removeAll()
    }
}

