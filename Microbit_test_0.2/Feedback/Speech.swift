//
//  Speech.swift
//  Microbit_test_0.2
//
//  Created by Ethan Shin on 3/4/2019.
//  Copyright © 2019 Ethan Shin. All rights reserved.
//

import Foundation
import AVFoundation

/// THE SPEECH FUNCTION DOES NOT CONSIDER REPS, AND HENCE INDEX 0 IS ROM INSTEAD OF REPS, SHIFTING EVERY INDEX BY 1. THE ORDER REMAINS THE SAME
class Speech: NSObject
{
    /// Stores the optimum desired range of range of motion and seconds per rep during a workout IN THIS SPECIFIC ORDER
    /// Verbal feedback will be given to the user if the average of a given value is not in the given optimum range
    let desiredRanges:[ClosedRange<Double>] = [70...101, 1.6...1.6.nextUp]
    
    /// A date of when the speech function was last used;
    /// Used to prevent continuous verbal feedback which can be annoying
    var timeOfLastCall:Date
    
    /// Structure containing dialogue for voice commands
    let speechStruct:SpeechStruct
    
    /// Stores the log of the average of the range of motion, seconds per rep, and similarity during a workout - as they become updated - IN THIS SPECIFIC ORDER
    var averageLogs:[[Double]]
    
    var utterance:AVSpeechUtterance
    var synthesizer:AVSpeechSynthesizer
    
    override init()
    {
        timeOfLastCall = Date()
        speechStruct = SpeechStruct()
        averageLogs = [[], []]
        utterance = AVSpeechUtterance()
        synthesizer = AVSpeechSynthesizer()
    }
    
    func appendToAverageLogs(index:Int, _ value:Double)
    {
        averageLogs[index-1].append(value)
    }
    
    /// Ensures there has been a sufficient time delay since the last verbal feedback
    ///
    /// - Returns: Whether the time delay is sufficient
    private func isSufficientDelay_betweenCalls() -> Bool
    {
        let currentTime = Date()
        if timeOfLastCall.addingTimeInterval(10) < currentTime { return true }
        return false
    }
    
    /// Ensures the average of the given statistic has constantly been out of range for the most recent 8 times it was updated
    ///
    /// - Parameter index: Index of the statistic, indicates whether the statistic desired is ROM or SPR
    /// - Returns: Whether the average has consistently been out of given range for most recent 8 updates
    private func isConsistent(index:Int) -> Bool
    {
        if averageLogs[index].endIndex > 8
        {
            for value in averageLogs[index][averageLogs[index].endIndex-8...averageLogs[index].endIndex-1]
            {
                // Return false if values are not consistently out of range
                if desiredRanges[index].contains(value) { return false }
            }
            return true
        }
        return false
    }
    
    /// Calculates the average percentage difference between two Double arrays.
    /// Negative result indicates leftData is less than rightData by that magnitude, positive result indicates the opposite
    ///
    /// - Parameters:
    ///   - leftData: Data from left side
    ///   - rightData: Data from right side
    /// - Returns: Percentage difference between the left and right data
    private func percentageDiff(leftData:[Double], rightData:[Double]) -> Double
    {
        if leftData.endIndex > 8 && rightData.endIndex > 8
        {
            var sum = 0.0
            
            for index in 1...8
            {
                sum += leftData[leftData.endIndex-index]/rightData[rightData.endIndex-index]
            }
            sum = sum/8.0 * 100 - 100
            
            return sum
        }
        return -1
    }
    
    /// Generates speech audio from a String.
    /// Credits to: https://www.hackingwithswift.com/example-code/media/how-to-convert-text-to-speech-using-avspeechsynthesizer-avspeechutterance-and-avspeechsynthesisvoice
    ///
    /// - Parameter dialogue: The String to be spoken
    private func outputVocal(dialogue:String)
    {
        print(dialogue)
        utterance = AVSpeechUtterance(string: "\(dialogue)")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.4
        
        synthesizer.speak(utterance)
    }
    

    
    /// Provide audio feedback if applicable for given statistic
    ///
    /// - Parameters:
    ///   - index: Index of statistic in averageLogs: 0 for ROM, 1 for SPR
    ///   - feedbackString: Array of String commands for given statistic
    ///   - leftData: Data from left side
    ///   - rightData: Data from right side
    private func provideFeedback(index:Int, feedbackString:[String], leftData:[Double], rightData:[Double])
    {
        // Address general bad form
        // index is subtracted by one intentionally; see line 14
        if isConsistent(index: index-1)
        {
            outputVocal(dialogue: feedbackString.first! + "\(abs(averageLogs[index-1].last!))" + feedbackString[1])
            timeOfLastCall = Date()
        }
        // Addressing noticeable differences between arms
        else
        {
            let diff = percentageDiff(leftData: leftData, rightData: rightData)
            
            // if difference between arms is greater than 8%
            if diff.magnitude > 8
            {
                if diff > 0 { outputVocal(dialogue: feedbackString[2] + "\(Int(abs(diff)))" + feedbackString[3]) }
                else { outputVocal(dialogue: feedbackString[4] + "\(Int(abs(diff)))" + feedbackString.last!) }
                timeOfLastCall = Date()
            }
        }
    }
    
    /// The main function for Speech (audio feedback), calls provideFeedback if basic conditions are met
    ///
    /// - Parameters:
    ///   - index: Index of statistic in averageLogs, but inflated by 1
    ///   - leftData: Data from left side
    ///   - rightData: Data from right side
    func provideFeedback_Main(index:Int, leftData:DataHolder, rightData:DataHolder)
    {
        if synthesizer.isSpeaking == false && isSufficientDelay_betweenCalls()
        {
            switch index
            {
            // If given statistic is range of motion
            case 1:
                print("IN CASE 0")
                provideFeedback(index: index, feedbackString: speechStruct.ROM, leftData: leftData.romAverageLog, rightData: rightData.romAverageLog)
                break
            // If given statistic is SPR
            case 2:
                print("IN CASE 1")
                provideFeedback(index: index, feedbackString: speechStruct.SPR, leftData: leftData.sprAverageLog, rightData: rightData.sprAverageLog)
                break
            default:
                break
            }
        }
    }
}
