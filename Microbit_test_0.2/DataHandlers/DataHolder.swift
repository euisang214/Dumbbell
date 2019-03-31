//
//  DataCollection.swift
//  Microbit_test_0.1
//
//  Created by Ethan Shin on 20/12/2018.
//  Copyright © 2018 Peter Wallen. All rights reserved.
//

import Foundation

struct DataHolder
{
    
    //
    // Short term data, used only for live processing
    //
    
    public var x:[Int16]
    public var x2:[Int16]
    public var x3:[Int16]
    public var x4:[Int16]
    public var threeD:[Int16]
    
    public var dX:[Int16]
    //for Similarity; 'd' indicates the difference from the previous value. All values inputted here are also smoothened
    public var dX_1:[Int16]
    public var dX2_1:[Int16]
    public var dX3_1:[Int16]
    public var dX4_1:[Int16]
    
    public var dX_2:[Int16]
    public var dX2_2:[Int16]
    public var dX3_2:[Int16]
    public var dX4_2:[Int16]
    
    public var dX_3:[Int16]
    public var dX2_3:[Int16]
    public var dX3_3:[Int16]
    public var dX4_3:[Int16]
    
    public var dX_4:[Int16]
    public var dX2_4:[Int16]
    public var dX3_4:[Int16]
    public var dX4_4:[Int16]
    public var dThreeD:[Int16]
    
    //for rep counting; "crossed" counts the number of times the microbit executes half a rep. 'raising' shows whether the microbit is declining or inclining
    public var raising:[Bool?]
    public var crossed:Int
    
    public var reps:Int//Presented to user
    
    //for rangeOfMotion
    public var rangeOfMotion:Int16 //Presented to user
    
    //for Speed; multiply the gap between the most recent odd index points by .p80
    public var crossedRunCountLog:[Int]
    public var secondsPerRep:Double
    
    //
    // Long term data, used for performance comparisons
    //
    
    
    
    init()
    {
        x = []
        x2 = []
        x3 = []
        x4 = []
        dX = []
        dX_1 = []
        dX2_1 = []
        dX3_1 = []
        dX4_1 = []
        dX_2 = []
        dX2_2 = []
        dX3_2 = []
        dX4_2 = []
        dX_3 = []
        dX2_3 = []
        dX3_3 = []
        dX4_3 = []
        dX_4 = []
        dX2_4 = []
        dX3_4 = []
        dX4_4 = []
        threeD = []
        dThreeD = []
        crossed = 0
        reps = 0
        rangeOfMotion = 0
        raising = []
        crossedRunCountLog = []
        secondsPerRep = 0
    }
    
    mutating func resetData()
    {
        x.removeAll()
        threeD.removeAll()
        dX.removeAll()
        dThreeD.removeAll()
        raising.removeAll()
        crossed = 0
        reps = 0
        rangeOfMotion = -1
        crossedRunCountLog.removeAll()
        secondsPerRep = 0
    }

}

struct UserAdvice
{
    public func outOfSyncMessage(speedDifferencePercentage:Double) -> String
    {
        if abs(Int32(speedDifferencePercentage)) > 5
        {
            if speedDifferencePercentage > 0
            {
                return "Right arm \(speedDifferencePercentage)% faster. Keep a steady pace"
            }
            else
            {
                return "Left arm \(speedDifferencePercentage)% faster. Keep a steady pace"
            }
        }
        return "Motion synchronised"
    }
}
