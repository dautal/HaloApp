import CoreBluetooth
import UIKit
import Combine
import SwiftUI

struct ContentView: View {
    @StateObject var bluetoothManager = BluetoothManager()
    @State private var isScanning = false
    @State private var isConnected = false
    

    var body: some View {
            NavigationView {
                ZStack {
                    if isConnected {
                        DeviceInfoView(batteryLevel: $bluetoothManager.batteryLevel, disconnectAction: {
                        bluetoothManager.disconnectPeripheral()
                        isConnected = false
                        })
                    } else {
                        DevicesListView(bluetoothManager: bluetoothManager, onConnect: {
                            if let selectedPeripheral = bluetoothManager.selectedPeripheral {
                                isConnected = true
                                bluetoothManager.connectToPeripheral(selectedPeripheral)
                            }
                        })
                    }
                }
                .navigationBarTitle(isConnected ? "Device Info" : "Bluetooth Devices")
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(isScanning ? "Stop Scanning" : "Start Scanning") {
                                        isScanning.toggle()
                                        if isScanning {
                                            bluetoothManager.startScanning()
                                        } else {
                                            bluetoothManager.stopScanning()
                                        }
                                    }
                                }
                            }
                .onAppear {
                    bluetoothManager.setTableView(tableView)
                    isConnected = bluetoothManager.isConnected
                }
                .onDisappear {
                    bluetoothManager.disconnectPeripheral()
                    isConnected = bluetoothManager.isConnected
                }
            }
            .onChange(of: bluetoothManager.selectedPeripheral, perform: { newValue in
                isConnected = newValue != nil
            })
            .onChange(of: isConnected, perform: { newValue in
                if newValue {
                    bluetoothManager.stopScanning()
                } else {
                    bluetoothManager.startScanning()
                }
            })
        }

        private var tableView: UITableView {
            let tableView = UITableView(frame: .zero, style: .plain)
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            tableView.dataSource = bluetoothManager
            tableView.delegate = bluetoothManager
            return tableView
        }
    }


struct DevicesListView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    var onConnect: () -> Void
    
    var body: some View {
        List {
            ForEach(bluetoothManager.peripherals.indices, id: \.self) { index in
                Button(action: {
                    bluetoothManager.connectToPeripheral(bluetoothManager.peripherals[index])
                    onConnect()
                }) {
                    Text(bluetoothManager.peripherals[index].name ?? "Unknown")
                }
            }
        }
        .navigationBarTitle("Bluetooth Devices")
        .onAppear {
            bluetoothManager.startScanning()
        }
        .onDisappear {
            bluetoothManager.stopScanning()
        }
    }
}


struct DeviceInfoView: View {
    @Binding var batteryLevel: Int
    var disconnectAction: () -> Void
    
    var body: some View {
        ZStack {
            Spacer()
            Text("Battery Level: \(batteryLevel)")
                .font(.title)
            Spacer()
            VStack {
                Spacer()
                Button("Disconnect") {
                    disconnectAction()
                }
            }
        }
    }
}
