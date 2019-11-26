//
//  ViewController.swift
//  FitnessBelt
//
//  Created by ThinkBiz on 06/09/19.
//  Copyright © 2019 Nirav. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    /// Tableview to display list of all bluetooth devices
    @IBOutlet weak var tblPeripheral: UITableView!

    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        BluetoothManager.sharedInstance.setupBluetooth()
        
        // Register the table view cell class and its reuse id
        tblPeripheral.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tblPeripheral.delegate = self
        tblPeripheral.dataSource = self
    }
}

extension ViewController: BluetoothManagerDelegate {
    func notifyValues(value: String) {
        
    }
    
    func reloadDevicesServices(arrServices: [CBService]) {
        
    }
    
    func connectedToDevices(devices: CBPeripheral, status: Int) {
        if status == 1 {
            let mainStoryboard = AppDelegate.sharedInstance.grabStoryboard()
            let servicesVC = mainStoryboard.instantiateViewController(withIdentifier: "ServicesVC") as! ServicesVC
            self.navigationController?.pushViewController(servicesVC, animated: true)
        }
        else{
            print("Error while connecting")
        }
    }
    
    func disconnectedToDevices(devices: CBPeripheral, status: Int) {
        
    }
    
    func reloadDevices(arrDevices: [CBPeripheral]) {
        tblPeripheral.delegate = self
        tblPeripheral.dataSource = self
        tblPeripheral.reloadData()
    }
    
    func reloadCharacteristic(arrCharacteristic: [CBCharacteristic]) {
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BluetoothManager.sharedInstance.arrDevices.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = (tblPeripheral.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?)!
        
        // set the text from the data model
        cell.textLabel?.text = BluetoothManager.sharedInstance.arrDevices[indexPath.row].name
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
       
        //BluetoothManager.sharedInstance.centralManager.stopScan()
        //BluetoothManager.sharedInstance.centralManager.connect(BluetoothManager.sharedInstance.arrDevices[indexPath.row], options: nil)
        BluetoothManager.sharedInstance.connectDevice(device: BluetoothManager.sharedInstance.arrDevices[indexPath.row])
    }
}


