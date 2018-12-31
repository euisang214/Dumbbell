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
    public func secondsPerRep(dataHolder:inout DataHolder)
    {
        let log = dataHolder.crossedRunCountLog
        if log.count >= 3
        {
            dataHolder.secondsPerRep = Double(Microbit.periodType.rawValue)/1000 * Double(log.last! - log[log.count-3])
        }
    }
}
