//
//  BluetoothManager.swift
//  FitnessBelt
//
//  Created by ThinkBiz on 06/09/19.
//  Copyright © 2019 Nirav. All rights reserved.
//

import UIKit
import CoreBluetooth

let heartRateServiceCBUUID = CBUUID(string: "0x180D")
let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")
let deviceNameCBUUID = CBUUID(string: "2A00")
let manufacturerNameCBUUID = CBUUID(string: "2A29")
let systemIDCBUUID = CBUUID(string: "2A23")

protocol BluetoothManagerDelegate {
    func reloadDevices(arrDevices: [CBPeripheral])
    func connectedToDevices(devices: CBPeripheral, status: Int)
    func disconnectedToDevices(devices: CBPeripheral, status: Int)
    
    func reloadDevicesServices(arrServices: [CBService])
    
    func reloadCharacteristic(arrCharacteristic: [CBCharacteristic])
    
    func notifyValues(value: String)
}

class BluetoothManager: NSObject {

    //Singleton for BluetoothManager to access class from anywhere
    static let sharedInstance = BluetoothManager()
    
    var delegate: BluetoothManagerDelegate?
    
    /// Core bluetooth manager
    var centralManager: CBCentralManager!
    
    /// Connected device
    var connectedPeripheral: CBPeripheral!
    
    /// Connected Characteristic
    var connectedCharacteristic: CBCharacteristic!
    
    /// Array of peripheral devices
    var arrDevices = [CBPeripheral]()
    
    /// Array of peripheral devices
    var arrServices = [CBService]()
    
    /// Array of Characteristic of selected service
    var arrCharacteristic = [CBCharacteristic]()
    
    let BLECharacteristic = "DFB1"
    
    
    func setupBluetooth() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func disconnectBluetooth() {
        centralManager.cancelPeripheralConnection(connectedPeripheral)
    }
    
    func connectDevice(device: CBPeripheral) {
        connectedPeripheral = device
        connectedPeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(connectedPeripheral)
    }
    
    func discoverCharacteristicsFor(service: CBService) {
        arrCharacteristic.removeAll()
        connectedPeripheral.discoverCharacteristics(nil, for: service)
    }
    
    func discoverValues(characteristic: CBCharacteristic) {
        if connectedCharacteristic != nil {
            connectedPeripheral.setNotifyValue(false, for: connectedCharacteristic)
        }
        connectedCharacteristic = characteristic
        if characteristic.properties.contains(.notify) {
            print("\(characteristic.uuid): properties contains .notify")
            connectedPeripheral.setNotifyValue(true, for: characteristic)
        }
        if characteristic.properties.contains(.read) {
            print("\(characteristic.uuid): properties contains .read")
            connectedPeripheral.readValue(for: characteristic)
        }
    }
    
    func disconnectValue() {
        if connectedCharacteristic != nil {
            connectedPeripheral.setNotifyValue(false, for: connectedCharacteristic)
        }
    }
    
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        print(peripheral.identifier.uuidString)
        if !arrDevices.contains(peripheral) {
            if peripheral.name != nil && peripheral.name!.count > 0 {
                arrDevices.append(peripheral)
                self.delegate?.reloadDevices(arrDevices: arrDevices)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        //heartRatePeripheral.discoverServices([heartRateServiceCBUUID])
        self.delegate?.connectedToDevices(devices: peripheral, status: 1)
        arrServices.removeAll()
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected!")
        self.delegate?.disconnectedToDevices(devices: peripheral, status: 1)
        
        arrDevices.removeAll()
        self.delegate?.reloadDevices(arrDevices: arrDevices)
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Error!")
        self.delegate?.connectedToDevices(devices: peripheral, status: 0)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)
            if !arrServices.contains(service) {
                arrServices.append(service)
                self.delegate?.reloadDevicesServices(arrServices: arrServices)
            }
            //peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    //func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic.uuid.name)
            
            if !arrCharacteristic.contains(characteristic) {
                arrCharacteristic.append(characteristic)
                self.delegate?.reloadCharacteristic(arrCharacteristic: arrCharacteristic)
            }
            
//            if characteristic.properties.contains(.read) {
//                print("\(characteristic.uuid): properties contains .read")
//                peripheral.readValue(for: characteristic)
//            }
//            if characteristic.properties.contains(.notify) {
//                print("\(characteristic.uuid): properties contains .notify")
//                peripheral.setNotifyValue(true, for: characteristic)
//            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        
//        if characteristic.uuid.uuidString == BLECharacteristic {
//            if(characteristic.value != nil) {
//                let stringValue = String(data: characteristic.value!, encoding: String.Encoding.utf8)!
//                self.delegate?.notifyValues(value: "stringValue: \(stringValue)")
//            }
//        }
        
        //print("test \(peripheral.readValue(for: characteristic))")
        
        switch characteristic.uuid {
        case bodySensorLocationCharacteristicCBUUID:
            let bodySensorLocation = bodyLocation(from: characteristic)
            //bodySensorLocationLabel.text = bodySensorLocation
            //print("bodySensorLocation: \(bodySensorLocation)")
            self.delegate?.notifyValues(value: "BodySensorLocation: \(bodySensorLocation)")
        case heartRateMeasurementCharacteristicCBUUID:
            let bpm = heartRate(from: characteristic)
            //onHeartRateReceived(bpm)
            let d = Date()
            let df = DateFormatter()
            df.dateFormat = "y-MM-dd H:m:ss.SSSS"
            let date = df.string(from: d)
            print("HeartRate: \(date) \(bpm)")
            self.delegate?.notifyValues(value: "HeartRate: \(bpm)")
        default:
            //print("Unhandled Characteristic UUID: \(characteristic.uuid)")
            if(characteristic.value != nil) {
                let stringValue = String(data: characteristic.value!, encoding: String.Encoding.utf8)
                self.delegate?.notifyValues(value: "Unhandled: \(stringValue ?? "No value")")
            }
            else{
                self.delegate?.notifyValues(value: "Unhandled: No value")
            }
        }
    }
    
    private func bodyLocation(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value,
            let byte = characteristicData.first else { return "Error" }
        
        switch byte {
        case 0: return "Other"
        case 1: return "Chest"
        case 2: return "Wrist"
        case 3: return "Finger"
        case 4: return "Hand"
        case 5: return "Ear Lobe"
        case 6: return "Foot"
        default:
            return "Reserved for future use"
        }
    }
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        // See: https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.heart_rate_measurement.xml
        // The heart rate mesurement is in the 2nd, or in the 2nd and 3rd bytes, i.e. one one or in two bytes
        // The first byte of the first bit specifies the length of the heart rate data, 0 == 1 byte, 1 == 2 bytes
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            // Heart Rate Value Format is in the 2nd byte
            return Int(byteArray[1])
        } else {
            // Heart Rate Value Format is in the 2nd and 3rd bytes
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
}
