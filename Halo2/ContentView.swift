import CoreBluetooth
import UIKit
import Combine
import SwiftUI

struct ContentView: View {
    @StateObject var bluetoothManager = BluetoothManager()
    @State private var isScanning = false
    @State private var isConnected = false
    @State private var isScanningAllowed = true
    @State private var voltage: Double = 0.0
    @State private var accel: Double = 0.0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {

        NavigationView {
            ZStack {
                if isConnected {
                    DeviceInfoView(voltage: $voltage, accel: $accel, bluetoothManager: bluetoothManager, disconnectAction: {
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
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading:
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "house.fill")
                            },
                trailing:
                Group {
                    if !isConnected {
                        Button(action: {
                            if isScanningAllowed {
                                isScanning.toggle()
                                if isScanning {
                                    bluetoothManager.startScanning()
                                } else {
                                    bluetoothManager.stopScanning()
                                }
                            }
                        }) {
                            HStack {
                                Text(isScanning ? "Stop Scanning" : "Start Scanning")
                                if isScanning {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                            .foregroundColor(.white)
                        }
                    }
                }
            )
            .font(.custom("Helvetica Neue", size: 18))
            .onAppear {
                bluetoothManager.setTableView(tableView)
                if bluetoothManager.isConnected {
                    isConnected = true
                }
            }
            .onDisappear {
                bluetoothManager.disconnectPeripheral()
                isConnected = bluetoothManager.isConnected
            }
            .onChange(of: bluetoothManager.selectedPeripheral, perform: { newValue in
                isConnected = newValue != nil
                updateIsScanningAllowed()
            })
            .onChange(of: isConnected, perform: { newValue in
                updateIsScanningAllowed()
            })
            .onReceive(bluetoothManager.$voltage) { level in
                voltage = level
            }
        }
    }
    
    private var tableView: UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = bluetoothManager
        tableView.delegate = bluetoothManager
        return tableView
    }
    
    private func updateIsScanningAllowed() {
        isScanningAllowed = !isConnected && bluetoothManager.selectedPeripheral == nil
    }
}


struct DevicesListView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    var onConnect: () -> Void
    @State private var isScanningAllowed = true
    
    var body: some View {
        List {
            ForEach(bluetoothManager.peripherals.indices, id: \.self) { index in
                Button(action: {
                    bluetoothManager.connectToPeripheral(bluetoothManager.peripherals[index])
                    onConnect()
                    isScanningAllowed = false
                }) {
                    Text(bluetoothManager.peripherals[index].name ?? "Unknown")
                }
            }
        }
        .onAppear {
            bluetoothManager.startScanning()
        }
        .onDisappear {
            bluetoothManager.stopScanning()
            isScanningAllowed = true
        }
    }
}


struct DeviceInfoView: View {
    @Binding var voltage: Double
    @Binding var accel: Double
    var bluetoothManager: BluetoothManager
    var disconnectAction: () -> Void
    
    var body: some View {
        ZStack {
            if bluetoothManager.updateVoltageAndAccel(voltage, accel) {
                Color.green
                    .ignoresSafeArea()
            } else {
                Color.red
                    .ignoresSafeArea()
            }
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
