/*
 MicrobitUI.swift
 
 Created by Peter Wallen on 01/01/2018
 Version 1.0
 
 Copyright © 2018 Peter Wallen.
 */
import UIKit
import CoreBluetooth

public protocol MicrobitUIDelegate {
    func startScanning()
    func stopScanning()
    func disconnect()
    func uartSend(message:String)
    func pinSetfor(read:[UInt8:Bool])
    func pinSetfor(analogue:[UInt8:Bool])
    func pinWrite(value:[UInt8:UInt8])
    func accelerometerSet(microbitPeripheral:CBPeripheral, period:PeriodType)
    func magnetometerSet(period:PeriodType)
    func temperatureSet(period:UInt16)
    func ledSet(matrix:[UInt8])
    func ledText(message:String,scrollRate:Int16)
    func event(register:[Int16])
    func raiseEvent(event:MicrobitEvent,value:UInt16)
}
// Dummy implementations to prevent functions specified in the MIcrobitUIDelegate being mandatory.
extension MicrobitUIDelegate {
    func startScanning() {}
    func stopScanning() {}
    func disconnect() {}
    func uartSend(message:String) {}
    func pinSetfor(read:[UInt8:Bool]) {}
    func pinSetfor(analogue:[UInt8:Bool]) {}
    func pinWrite(value:[UInt8:UInt8]) {}
    func accelerometerSet(microbitPeripheral:CBPeripheral, period:PeriodType){}
    func magnetometerSet(period:PeriodType) {}
    func temperatureSet(period:UInt16){}
    func ledSet(matrix:[UInt8]){}
    func ledText(message:String,scrollRate:Int16){}
    func event(register:[Int16]){}
    func raiseEvent(event:MicrobitEvent,value:UInt16){}
}

public class MicrobitLog
{
    public func getProcessedLog(log:[String]) -> String
    {
        var logBuffer = ""
        for entry in log
        {
            logBuffer = logBuffer + entry + "\n\n"
        }
        
        return logBuffer
        //let stringLength = logView.text.count
        //logView.scrollRangeToVisible(NSMakeRange(stringLength-1, 0))
    }
}

public class MicrobitAccelerometer
{
    public var delegate:MicrobitUIDelegate?
    
    var xValue:Int16
    var yValue:Int16
    var zValue:Int16
    
    init()
    {
        xValue = 0
        yValue = 0
        zValue = 0
    }
    
    let periodControl = UISegmentedControl(items:["1ms","2ms","5ms","10ms","20ms","80ms","160ms","640ms"])
    
    public func update(x:Int16,y:Int16,z:Int16)
    {
        xValue = x
        yValue = y
        zValue = z
    }
    
    public func setPeriod(microbitPeripheral:CBPeripheral)
    {
        periodControl.selectedSegmentIndex = 5
        delegate?.accelerometerSet(microbitPeripheral: microbitPeripheral, period:Microbit.periodType)
    }
    
    public func getXValue() -> Int16 { return xValue }
    
    public func getYValue() -> Int16 { return yValue }
    
    public func getZValue() -> Int16 { return zValue }
}
