//
//  RangeOfMotion.swift
//  Microbit_test_0.2
//
//  Created by Ethan Shin on 29/12/2018.
//  Copyright © 2018 Ethan Shin. All rights reserved.
//

import Foundation

/// RangeOfMotion will be instantiated in the RepCount class to easily identify when dataHolder.crossed increases
/// Since RepCount accounts for a single microbit, RangeOfMotion only needs to account for one microbit
class RangeOfMotion
{
    /// Stores ONLY the acceleration between each rep; its contents are reset each time a rep is conducted
    private var recentReps:[Double]
    
    /// Stores the default range of motion: based on the first full rep
    private var standardDifference:Double?
    
    init()
    {
        recentReps = []
        standardDifference = nil
    }
    
    /// Appends the most recent x acceleration value to recentReps
    ///
    /// - Parameter x: The x acceleration value
    public func updateRecent(x:Double) { recentReps.append(x) }

    /// Updates the ROM (Range Of Motion) when a rep is completed; when dataHolder.crossed%2==0
    ///
    /// - Parameters:
    ///   - dataHolder: The DataHolder to be examined for its ROM
    ///   - runCount: The number of times accerlerometer data has been passed to the iOS device
    public func updateROM(dataHolder:inout DataHolder, runCount:Int)
    {
        //a variable that will contain the most recent range travelled, in double; aka the difference between the greatest and smallest accelerometer values
        let range:Double = abs( Double(recentReps.max()! - recentReps.min()!) )
 
        if standardDifference != nil
        {
            if range < standardDifference! { dataHolder.rom = range/standardDifference!*Double(100) }
            //if most recent range travelled is greater than the standard, this range becomes the standard
            else
            {
                standardDifference = range
                dataHolder.rom = 100
            }
            //getting percentage
            if dataHolder.romAverage == 0 { dataHolder.romAverage = dataHolder.rom }
            else { dataHolder.romAverage = (dataHolder.rom+dataHolder.romAverage)/2 }
        }
        else
        {
            standardDifference = range
            dataHolder.rom = 100
        }
        // Removing all
        recentReps.removeAll()
    }
    
    
    /// Reset all local variables in this class in preperation for next workout set
    public func resetData()
    {
        recentReps.removeAll()
        standardDifference = nil
    }
}

