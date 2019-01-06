//
//  Similarity.swift
//  Microbit_test_0.1
//
//  Created by Ethan Shin on 25/12/2018.
//  Copyright © 2018 Peter Wallen. All rights reserved.
//

import Foundation

class Similarity
{
    //gets the 'd' - difference - between most recent data points for the given
    //array - in DataHolder - and presents it as a percentage.
    //
    //The percentage is given as the difference between the right and
    //left side, divided by the smaller of the two
    //
    //Assesses the percentage difference between rate of change of the most recent measurements
    public func liveSimilarity(leftArray:[Int16], rightArray:[Int16]) -> Double
    {
        var sum = 0.0
        let leftLast = leftArray.endIndex-1
        let rightLast = rightArray.endIndex-1
        if leftArray.count>=32 && rightArray.count>=32
        {
            for index in 0...31
            {
                sum += Double(min(abs(leftArray[leftLast-index]), abs(rightArray[rightLast-index])))/Double(max(abs(leftArray[leftLast-index]), abs(rightArray[rightLast-index])))*100
            }
            return sum/Double(32)
        }
        return 0
    }
    
    //uses Jaccard Similarity algorithm
    //Assesses the overall corellation between the motion of the two given arrays
    public func overallSimilarity(leftArray:[Int16], rightArray:[Int16]) -> Int
    {
        if leftArray.count>=32 && rightArray.count>=32
        {
            let leftSet = Set(leftArray.suffix(from: leftArray.count-32))
            let rightSet = Set(rightArray.suffix(from: rightArray.count-32))
            
            return Int(abs(Double(leftSet.intersection(rightSet).count) / Double(leftSet.union(rightSet).count) * 100))
        }
        return 0
    }
}
