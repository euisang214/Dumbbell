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
    public var x:[Double]
    public var threeD:[Double]
    
    //for Similarity; 'd' indicates the difference from the previous value. All values inputted here are also smoothened
    public var dX:[Double]
    public var dThreeD:[Double]
    
    //for rep counting; "crossed" counts the number of times the microbit executes half a rep. 'raising' shows whether the microbit is declining or inclining
    public var crossingZero:[Bool?]
    public var crossed:Int
    {
        didSet
        {
            Speed.updateSPR(dataHolder: &self)
        }
    }
    public var reps:Int
    
    //for rangeOfMotion
    public var rom:Double //Presented to user
    public var romAverage:Double
    {
        didSet
        {
            romAverageLog.append(oldValue)
        }
    }
    public var romAverageLog:[Double]
    
    //for Speed; multiply the gap between the most recent odd index points by .p30
    public var crossedRunCountLog:[Int]
    public var spr:Double
    public var sprAverage:Double
    {
        didSet
        {
            sprAverageLog.append(oldValue)
        }
    }
    public var sprAverageLog:[Double]
    
    //
    // Long term data, used for performance comparisons
    //
    
    
    
    init()
    {
        x = []
        dX = []
        threeD = []
        dThreeD = []
        crossed = 0
        reps = 0
        rom = 0
        romAverage = 0
        crossingZero = []
        crossedRunCountLog = []
        spr = 0
        sprAverage = 0
        sprAverageLog = []
        romAverageLog = []
    }
    
    mutating func resetData()
    {
        x.removeAll()
        threeD.removeAll()
        dX.removeAll()
        dThreeD.removeAll()
        crossingZero.removeAll()
        crossed = 0
        reps = 0
        rom = -1
        crossedRunCountLog.removeAll()
        spr = 0
    }

}
