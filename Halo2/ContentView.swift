import CoreBluetooth
import UIKit
import Combine
import SwiftUI
import UserNotifications


struct ContentView: View {
    @StateObject var bluetoothManager = BluetoothManager()
    @State private var isScanning = false
    @State private var isConnected = false
    @State private var isScanningAllowed = true
    @State private var Cover_Status: Int = 1
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color("Background1"), Color("Background2")]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                if isConnected {
                    DeviceInfoView(Cover_Status: $Cover_Status, disconnectAction: {
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
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss() // Dismiss the view when the Home button is tapped
                }) {
                    Image(systemName: "house.fill")
                        .font(.title)
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
                updateIsScanningAllowed()
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
            .onReceive(bluetoothManager.$Cover_Status) { level in
                Cover_Status = level
                if Cover_Status == 0 {
                    sendNotification()
                }
            }
        }
    }
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Cover is gone!"
        content.body = "Please check your device."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
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
        .navigationBarTitle("Bluetooth Devices")
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
    @Binding var Cover_Status: Int
    var disconnectAction: () -> Void
    let notificationCenter = UNUserNotificationCenter.current()
    
    var body: some View {
        ZStack {
            if Cover_Status == 1 {
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
