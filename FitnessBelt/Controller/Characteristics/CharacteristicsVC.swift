//
//  CharacteristicsVC.swift
//  FitnessBelt
//
//  Created by ThinkBiz on 06/09/19.
//  Copyright © 2019 Nirav. All rights reserved.
//

import UIKit
import CoreBluetooth

class CharacteristicsVC: UIViewController {
    
    /// Tableview to display list of all characteristics of selected services
    @IBOutlet weak var tblcharacteristics: UITableView!
    
    /// UILabel to display Notified value
    @IBOutlet weak var lblValue: UILabel!
    
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide navigationBar
        self.navigationController?.isNavigationBarHidden = true
        
        initialization()
    }
    
    
    //MARK:- Initialization
    func initialization() {
        
        // Alloc bluetooth class
        //        let objcBluetooth = BluetoothManager()
        //        objcBluetooth.delegate = self
        BluetoothManager.sharedInstance.delegate = self
        //BluetoothManager.sharedInstance.setupBluetooth()
        
        // Register the table view cell class and its reuse id
        tblcharacteristics.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tblcharacteristics.delegate = self
        tblcharacteristics.dataSource = self
    }
    
    //MARK:- Action
    @IBAction func goBack(_ sender: UIButton) {
        BluetoothManager.sharedInstance.disconnectValue()
        BluetoothManager.sharedInstance.delegate = nil
        self.navigationController?.popViewController(animated: true)
    }
}

extension CharacteristicsVC: BluetoothManagerDelegate {
    func notifyValues(value: String) {
        lblValue.text = value
    }
    
    func reloadCharacteristic(arrCharacteristic: [CBCharacteristic]) {
        tblcharacteristics.reloadData()
    }
    
    func reloadDevicesServices(arrServices: [CBService]) {
        //tblcharacteristics.reloadData()
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
    
}

extension CharacteristicsVC: UITableViewDelegate, UITableViewDataSource {
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BluetoothManager.sharedInstance.arrCharacteristic.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = (tblcharacteristics.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?)!
        
        // set the text from the data model
        cell.textLabel?.text = "\(BluetoothManager.sharedInstance.arrCharacteristic[indexPath.row].uuid.name ?? "")"
       
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
        BluetoothManager.sharedInstance.discoverValues(characteristic: BluetoothManager.sharedInstance.arrCharacteristic[indexPath.row])
    }
}
