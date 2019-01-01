//
//  Calculation.swift
//  Microbit_test_0.1
//
//  Created by Ethan Shin on 20/12/2018.
//  Copyright © 2018 Peter Wallen. All rights reserved.
//

import Foundation

class Calculation
{
    private func threeDAcceleration(x:Int16, y:Int16, z:Int16) -> Int16
    {
        return Int16(pow( pow(Double(x), 2)+pow(Double(x), 2)+pow(Double(x), 2) , 1/3).rounded())
        //return 1
    }
    
    //functions for masterRecordData()
    
    private func smoothen(record:[Int16]?, rawValue:Int16) -> Int16
    {
        if !(record?.isEmpty)!
        {
            return Int16(0.08*Double(rawValue)+(1-0.08)*Double((record?.last)!))
        }
        return rawValue
    }
    
    public func updateDataHolder(dataHolder: inout DataHolder, x:Int16, y:Int16, z:Int16)
    {
        //let twoD = twoDAcceleration(x: x, y: y)
        let threeD = threeDAcceleration(x: x, y: y, z: z)
        
        dataHolder.x.append(smoothen(record: dataHolder.x, rawValue: x))
        dataHolder.threeD.append(smoothen(record: dataHolder.threeD, rawValue: threeD))
        
        if dataHolder.x.count >= 2
        {
            dataHolder.dX.append(dataHolder.x.last! - dataHolder.x[dataHolder.x.count-2])
            dataHolder.dThreeD.append(dataHolder.threeD.last! - dataHolder.threeD[dataHolder.threeD.count-2])
        }
    }
}
