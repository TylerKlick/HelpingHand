////
////  ViewController.swift
////  Helping Hand
////
////  Created by Tyler Klick on 6/17/25.
////
//
//import UIKit
//import CoreBluetooth
//
//class ViewController: UIViewController {
//    
//    @IBOutlet weak var batteryImage : UIImageView!
//    @IBOutlet weak var lightSwitch : UISwitch!
//    
//    var centralManager : CBCentralManager!
//    var peripheral : CBPeripheral!
//    private var txCharacteristic: CBCharacteristic!
//    private var rxCharacteristic: CBCharacteristic!
//    private var peripheralArray: [CBPeripheral] = []
//    private var rssiArray = [NSNumber]()
//    private var timer = Timer()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        centralManager = CBCentralManager(delegate: self, queue: nil)
//    }
//}
