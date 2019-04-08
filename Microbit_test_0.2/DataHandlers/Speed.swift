//
//  Speed.swift
//  Microbit_test_0.2
//
//  Created by Ethan Shin on 30/12/2018.
//  Copyright © 2018 Ethan Shin. All rights reserved.
//

import Foundation

class Speed
{
    /// Updates the SPR (Seconds Per Repetition) for the given DataHolder
    ///
    /// - Parameter dataHolder: The DataHolder to be examined for its SPR
    static public func updateSPR(dataHolder:inout DataHolder)
    {
        let log = dataHolder.crossedRunCountLog
        if log.count >= 3
        {
            dataHolder.spr = Double(Microbit.periodType.rawValue)/1000 * Double(log.last! - log[log.count-3])
            if dataHolder.sprAverage == 0 { dataHolder.sprAverage = dataHolder.spr }
            else { dataHolder.sprAverage = (dataHolder.spr+dataHolder.sprAverage)/2 }
        }
    }
}
