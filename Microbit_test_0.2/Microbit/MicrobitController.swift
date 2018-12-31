
/*
 MicrobitUIController.swift
 
 Created by Peter Wallen on 11/12/2017
 Version 1.0
 */
import UIKit
import CoreBluetooth

public protocol MicrobitAccelerometerControllerDelegate
{
    func updateLogView(_ log:String)
    func updateAccelerometerValues(isRightSide:Bool)
    func connectionStatUpdate(isConnected:[Bool])
}

class MicrobitAccelerometerController: MicrobitUIDelegate,MicrobitDelegate
{
    public var delegate:MicrobitAccelerometerControllerDelegate?
    
    var logText:String
    var microbit:Microbit?
    var microbitLog:MicrobitLog?
    var microbitAccelerometer:MicrobitAccelerometer?
    
    init(isRightSide:Bool)
    {
        logText = ""
        microbit = Microbit("BBC micro:bit")
        microbitLog = MicrobitLog()
        microbitAccelerometer = MicrobitAccelerometer()
        microbit?.delegate = self
        microbitAccelerometer?.delegate = self
    }
    
    // MARK: Implement required MicrobitUIDelegate functions
    public func startScanning()
    {
        microbit?.startScanning()
    }
    public func stopScanning()
    {
        microbit?.stopScanning()
    }
    public func disconnect()
    {
        microbit?.disconnect()
    }
    
    public func accelerometerSet(microbitPeripheral: CBPeripheral, period: PeriodType)
    {
        microbit?.accelerometer(microbitPeripheral: microbitPeripheral, period: period)
    }
    
    // MARK: Implement required MicrobitDelegate functions
    func accelerometerData(x: Int16, y: Int16, z: Int16, isRightSide:Bool)
    {
        microbitAccelerometer?.update(x:x,y:y,z:z)
        delegate?.updateAccelerometerValues(isRightSide: isRightSide)
    }
    
    func logUpdated(_ log: [String])
    {
        logText = microbitLog?.getProcessedLog(log: log) ?? ""
        delegate?.updateLogView(logText)
    }
    
    func serviceAvailable(microbitPeripheral:CBPeripheral, service:ServiceName)
    {
        if service == .Accelerometer
        {
            microbitAccelerometer?.setPeriod(microbitPeripheral: microbitPeripheral)
        }
    }
    
    public func connectionStatChangeNotif(isConnected:[Bool])
    {
        delegate?.connectionStatUpdate(isConnected: isConnected)
    }
    
    public func getLogText() -> String { return logText }
}
