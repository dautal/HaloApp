import CoreBluetooth
import UIKit
import Combine

class BluetoothManager: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    private var tableView: UITableView?
    @Published var peripherals: [CBPeripheral] = []
    internal var selectedPeripheral: CBPeripheral?
    private var cancellables: Set<AnyCancellable> = []
    @Published var isConnected = false
    @Published var voltage: Double = 0
    @Published var accel: Double = 0
    @Published var oldvoltage: Double = 0
    @Published var voltageInt: Double = 0
    @Published var threshold: Double = 1.8
    
    
    private let voltageServiceUUID = CBUUID(string: "75340d9a-b70d-11ed-afa1-0242ac120002")
    private let voltageCharacteristicUUID = CBUUID(string: "84244464-b70d-11ed-afa1-0242ac120002")

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        threshold = UserDefaults.standard.double(forKey: "threshold")
    }
    
    func saveThresholdToUserDefaults() {
        UserDefaults.standard.setValue(threshold, forKey: "threshold")
    }

    func startScanning() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func stopScanning() {
        centralManager.stopScan()
    }

    func setTableView(_ tableView: UITableView) {
        self.tableView = tableView
        tableView.dataSource = self
        tableView.delegate = self
    }

    func connectToPeripheral(_ peripheral: CBPeripheral) {
            centralManager.stopScan()
            selectedPeripheral = peripheral
            selectedPeripheral?.delegate = self
            centralManager.connect(peripheral, options: nil)
    }

    func disconnectPeripheral() {
        if let selectedPeripheral = selectedPeripheral {
                centralManager.cancelPeripheralConnection(selectedPeripheral)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("Thres: \(self.threshold)")
        guard error == nil else {
            print("Error updating characteristic value: \(error!.localizedDescription)")
            return
        }
        guard let value = characteristic.value else {
            print("No value found for characteristic: \(characteristic)")
            return
        }
        if characteristic.uuid == voltageCharacteristicUUID {
            self.oldvoltage=voltageInt
            let voltageString = String(data: value, encoding: .utf8) ?? ""
            let components = voltageString.split(separator: ",")
            if let voltageValue = Double(components.first ?? "") {
                self.voltageInt = Double(voltageValue)
                self.voltage = voltageInt
                //print("Voltage: \(self.voltage)")
            }
            if let accelValue = Double(components.last ?? "") {
                self.accel = accelValue
                //print("Accel: \(self.accel)")
            }
        }
    }
    
    func updateVoltageAndAccel(_ voltage: Double, _ accel: Double) -> Bool {
        if self.accel > 0.9 && self.accel < 1.1 && abs(voltage - oldvoltage) > threshold {
            return false
        } else {
            return true
        }
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("Bluetooth status is unknown")
        case .resetting:
            print("Bluetooth is resetting")
        case .unsupported:
            print("Bluetooth is not supported on this device")
        case .unauthorized:
            print("Bluetooth is not authorized on this device")
        case .poweredOff:
            print("Bluetooth is powered off")
        case .poweredOn:
            print("Bluetooth is powered on")
        @unknown default:
            print("Unknown Bluetooth status")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            guard advertisementData[CBAdvertisementDataIsConnectable] as? Bool == true else {
                return // Ignore non-connectable devices
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                guard let name = peripheral.name, name != "Unknown" else {
                    return // ignore the peripheral if the name is "Unknown"
                }
                if !self.peripherals.contains(peripheral) {
                    print("Discovered \(peripheral.name ?? "Unknown") at \(RSSI)dB")
                    self.peripherals.append(peripheral)
                    if let tableView = self.tableView {
                        tableView.reloadData()
                }

            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            print("Connected to \(peripheral.name ?? "Unknown")")
            selectedPeripheral = peripheral
            stopScanning()
            peripheral.delegate = self
            peripheral.discoverServices([voltageServiceUUID])
            isConnected = true
        }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown")")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "Unknown")")
        selectedPeripheral = nil
        isConnected = false
    }
}


extension BluetoothManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let peripheral = peripherals[indexPath.row]
        cell.textLabel?.text = peripheral.name ?? "Unknown"
        return cell
    }
}

extension BluetoothManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = peripherals[indexPath.row]
        connectToPeripheral(peripheral)
    }
}
extension BluetoothManager: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let services = peripheral.services else {
            print("No services found for peripheral: \(peripheral)")
            return
        }
        for service in services {
            if service.uuid == voltageServiceUUID {
                peripheral.discoverCharacteristics([voltageCharacteristicUUID], for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Error discovering characteristics: \(error!.localizedDescription)")
            return
        }
        guard let characteristics = service.characteristics else {
            print("No characteristics found for service: \(service)")
            return
        }
        for characteristic in characteristics {
            if characteristic.uuid == voltageCharacteristicUUID {
                print("Found voltage characteristic: \(characteristic)")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
}
