//
//  ServicesVC.swift
//  FitnessBelt
//
//  Created by ThinkBiz on 06/09/19.
//  Copyright © 2019 Nirav. All rights reserved.
//

import UIKit
import CoreBluetooth

class ServicesVC: UIViewController {

    /// Tableview to display list of all bluetooth devices services
    @IBOutlet weak var tblServices: UITableView!
    
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide navigationBar
        self.navigationController?.isNavigationBarHidden = true
        
        initialization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !(BluetoothManager.sharedInstance.delegate != nil) {
            BluetoothManager.sharedInstance.delegate = self
        }
    }
    
    
    //MARK:- Initialization
    func initialization() {
        
        // Alloc bluetooth class
        //        let objcBluetooth = BluetoothManager()
        //        objcBluetooth.delegate = self
        BluetoothManager.sharedInstance.delegate = self
        //BluetoothManager.sharedInstance.setupBluetooth()
        
        // Register the table view cell class and its reuse id
        tblServices.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tblServices.delegate = self
        tblServices.dataSource = self
    }
    
    //MARK:- Action
    @IBAction func goBack(_ sender: UIButton) {
        if BluetoothManager.sharedInstance.connectedPeripheral.state == .connected {
            BluetoothManager.sharedInstance.disconnectBluetooth()
        }
        else{
            BluetoothManager.sharedInstance.delegate = nil
            self.navigationController?.popViewController(animated: true)
            BluetoothManager.sharedInstance.arrDevices.removeAll()
            BluetoothManager.sharedInstance.centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
}

extension ServicesVC: BluetoothManagerDelegate {
    func notifyValues(value: String) {
        
    }
    
    func reloadDevicesServices(arrServices: [CBService]) {
        tblServices.reloadData()
    }
    
    func reloadDevices(arrDevices: [CBPeripheral]) {
        
    }
    
    func connectedToDevices(devices: CBPeripheral, status: Int) {
        
    }
    
    func disconnectedToDevices(devices: CBPeripheral, status: Int) {
        if status == 1 {
            BluetoothManager.sharedInstance.delegate = nil
            self.navigationController?.popToRootViewController(animated: true)
        }
        else{
            print("Error while disconnecting")
        }
    }
    
    func reloadCharacteristic(arrCharacteristic: [CBCharacteristic]) {
        
    }
    
}

extension ServicesVC: UITableViewDelegate, UITableViewDataSource {
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BluetoothManager.sharedInstance.arrServices.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = (tblServices.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?)!
        
        // set the text from the data model
        cell.textLabel?.text = "\(BluetoothManager.sharedInstance.arrServices[indexPath.row].uuid)"
        print("\(BluetoothManager.sharedInstance.arrServices[indexPath.row].includedServices)")
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
        BluetoothManager.sharedInstance.discoverCharacteristicsFor(service: BluetoothManager.sharedInstance.arrServices[indexPath.row])
        let mainStoryboard = AppDelegate.sharedInstance.grabStoryboard()
        let characteristicsVC = mainStoryboard.instantiateViewController(withIdentifier: "CharacteristicsVC") as! CharacteristicsVC
        self.navigationController?.pushViewController(characteristicsVC, animated: true)
    }
}
