//
//  Home.swift
//  Microbit_test_0.2
//
//  Created by Ethan Shin on 26/12/2018.
//  Copyright © 2018 Ethan Shin. All rights reserved.
//

import UIKit

protocol HomeDelegate
{
    func prepareForNextSet()
}

class Home: UIViewController, UpdateConnectionStatLabelDelegate, LiveAnalysisDelegate {
    
    public static var delegate:HomeDelegate?

    //  @IBOutlet weak var logView: UITextView!

    @IBOutlet weak var connectionRight: UILabel!
    @IBOutlet weak var connectionLeft: UILabel!
    @IBOutlet weak var connect: UIButton!
    @IBOutlet weak var disconnect: UIButton!
    
    @IBAction func startScanning(_ sender: UIButton)
    {
        connect.setTitle("Connecting", for: .normal)
        connect.isEnabled = false
        ViewController.microbitController?.startScanning()
        disconnect.isEnabled = true
    }
    
    @IBAction func stopScanning(_ sender: UIButton)
    {
        ViewController.microbitController?.stopScanning()
    }
    
    @IBAction func disconnect(_ sender: UIButton)
    {
        disconnectMicrobits()
    }
    
    private func connectionLabelUpdate(connectionStat:UILabel!, isConnected: Bool)
    {
        switch isConnected
        {
        case true:
            connectionStat.text = "Connected"
            connectionStat.textColor = UIColor.green
        case false:
            connectionStat.text = "Not Connected"
            connectionStat.textColor = UIColor.red
        }
    }
    
    // MARK: Implementaiton required for UpdateConnectionStatLabelDelegate
    public func updateConnectionStatLabel(isConnected: [Bool])
    {
        connectionLabelUpdate(connectionStat: connectionRight, isConnected: isConnected.first!)
        connectionLabelUpdate(connectionStat: connectionLeft, isConnected: isConnected.last!)
        
        if isConnected.first == true && isConnected.last == true
        {
            connect.setTitle("Connected", for: .normal)
            disconnect.isEnabled = true
        }
    }
    
    //MARK: Implementation required for LiveAnalysisDelegate
    public func disconnectMicrobits()
    {
        let microbit = ViewController.microbitController?.microbit
        if connect.currentTitle == "Connecting"
        {
            microbit!.stopScanning()
            disconnect.isEnabled = false
            connect.setTitle("Connect", for: .normal)
            connect.isEnabled = true
            microbit!.disconnect()
        }
        else
        {
            microbit!.disconnect()
            let after = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: after)
            {
                self.connect.isEnabled = true
                self.connect.setTitle("Connect", for: .normal)
                self.disconnect.isEnabled = false
                self.disconnect.setTitle("Disconnected", for: .normal)
            }
        }
        Microbit.microbitPeripherals?.removeAll()
        Home.delegate?.prepareForNextSet()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        disconnect.isEnabled = false
        ViewController.updateConnectionStatLabelDelegate = self
        LiveAnalysis.liveAnalysisDelegate = self
        
        connectionLeft.text = "Not Connected"
        connectionLeft.textColor = UIColor.red
        connectionRight.text = "Not Connected"
        connectionRight.textColor = UIColor.red
        
        connectionRight.layer.backgroundColor  = UIColor.lightGray.cgColor
        connectionRight.layer.cornerRadius = 5
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
