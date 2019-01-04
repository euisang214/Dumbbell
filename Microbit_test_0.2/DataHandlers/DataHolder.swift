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
    public var x:[Int16]
    public var threeD:[Int16]
    
    public var dX:[Int16]
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
    
    init()
    {
        x = []
        dX = []
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
