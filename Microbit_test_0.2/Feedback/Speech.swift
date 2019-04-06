//
//  Speech.swift
//  Microbit_test_0.2
//
//  Created by Ethan Shin on 3/4/2019.
//  Copyright © 2019 Ethan Shin. All rights reserved.
//

import Foundation
import AVFoundation

class Speech
{
    // THE SPEECH FUNCTION DOES NOT CONSIDER REPS, AND HENCE INDEX 0 IS ROM INSTEAD OF REPS, SHIFTING EVERY INDEX BY 1. THE ORDER REMAINS THE SAME
    
    // Stores the optimum desired range of range of motion, seconds per rep, and similarity during a workout IN THIS SPECIFIC ORDER
    // Verbal feedback will be given to the user if the average of a given value is not in the given optimum range
    let desiredRanges:[ClosedRange<Double>] = [0...78, 1.6...1.6.nextUp, 90...101]
    var isPlaying:Bool
    
    // A date of when the speech function was last used
    // Used to prevent continuous verbal feedback which can be annoying
    var timeOfLastCall:Date
    
    // Structure containing dialogue for voice commands
    let speechStruct:SpeechStruct
    
    // Stores the log of the average of the range of motion, seconds per rep, and similarity during a workout - as they become updated - IN THIS SPECIFIC ORDER
    var averageLogs:[[Double]]
    
    init()
    {
        isPlaying = false
        timeOfLastCall = Date()
        speechStruct = SpeechStruct()
        averageLogs = [[]]
    }
    
    func appendToAverageLogs(index:Int, _ value:Double)
    {
        averageLogs[index-1].append(value)
    }
    
    // Ensures there has been a sufficient time delay since the last verbal feedback
    private func isSufficientDelay_betweenCalls() -> Bool
    {
        let currentTime = Date()
        if timeOfLastCall.addingTimeInterval(7) < currentTime { return true }
        return false
    }
    
    // Ensures the average of the given statistic has constantly been out of range for the most recent 8 times it was updated
    // Index of the statistic, in terms of desiredRanges and averageLogs
    private func isConsistent(index:Int) -> Bool
    {
        for value in averageLogs[index][averageLogs[index].endIndex-8...averageLogs[index].endIndex-1]
        {
            // Return false if values are not consistently out of range
            if desiredRanges[index].contains(value) { return false }
        }
        return true
    }
    
    // Negative result indicates leftData is less than rightData by that magnitude, positive result indicates the opposite
    // Returns the percentage difference between the left and right data
    private func percentageDiff(leftData:[Double], rightData:[Double]) -> Double
    {
        var sum = 0.0
        
        for index in 1...8
        {
            sum += leftData[leftData.endIndex-index]/rightData[rightData.endIndex-index]
        }
        sum = sum/8.0 * 100 - 100
        
        return sum
    }
    
    // Credits to: https://www.hackingwithswift.com/example-code/media/how-to-convert-text-to-speech-using-avspeechsynthesizer-avspeechutterance-and-avspeechsynthesisvoice
    // Speaks audio from dialogue
    private func outputVocal(dialogue:String)
    {
        let utterance = AVSpeechUtterance(string: "\(dialogue)")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.1
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    //
    private func provideFeedback(index:Int, feedbackString:[String], leftData:[Double], rightData:[Double])
    {
        // Address general bad form
        // index is subtracted by one intentionally; see line 14
        if isConsistent(index: index-1) { outputVocal(dialogue: feedbackString.first! + "\(abs(averageLogs[index-1].last!))" + feedbackString[1]) }
            
        // Addressing if there are performance differences between arms
        else
        {
            let diff = percentageDiff(leftData: leftData, rightData: rightData)
            
            // if difference between arms is greater than 8%
            if diff.magnitude > 8
            {
                if diff > 0 { outputVocal(dialogue: feedbackString[2] + "\(Int(abs(diff)))" + feedbackString[3]) }
                else { outputVocal(dialogue: feedbackString[4] + "\(Int(abs(diff)))" + feedbackString.last!) }
            }
        }
    }
    
    // index: Index of the statistic, in terms of desiredRanges and averageLogs
    func provideFeedback_Main(index:Int, leftData:DataHolder, rightData:DataHolder)
    {
        if isPlaying == false && isSufficientDelay_betweenCalls()
        {
            switch index
            {
            // If given statistic is range of motion
            case 0:
                provideFeedback(index: index, feedbackString: speechStruct.ROM, leftData: leftData.romAverageLog, rightData: rightData.romAverageLog)
                break
            // If given statistic is SPR
            case 1:
                provideFeedback(index: index, feedbackString: speechStruct.SPR, leftData: leftData.sprAverageLog, rightData: rightData.sprAverageLog)
                break
                /*
            // If given statistic is similarity
            // Does not call provideFeedback since similarity can just be reported. It cannot be separated to left and right because similarity is a single value calculated by using leftData and rightData.
            case 2:
                if isConsistent(index: index-1) { outputVocal(dialogue: speechStruct.SIMIL.first! + "\(abs(averageLogs[index-1].last!))" + speechStruct.SIMIL[1]) }
                break*/
            default:
                break
            }
        }
    }
}
