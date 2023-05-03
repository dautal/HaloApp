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
    @State private var isRed = false
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
            .navigationBarTitle(Text(bluetoothManager.selectedPeripheral?.name ?? "Bluetooth Devices"))
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
                                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                }
                            }
                            .foregroundColor(.blue)
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
                    voltage=level
            }
        }
        .background(Color.red)
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
    
    @State private var isEditing = false
    @State private var thresholdText = ""
    @State private var isRed = false
    @State private var ready = false
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            if (!isRed && bluetoothManager.updateVoltageAndAccel(voltage, accel))||ready==false {
                Color.green
                    .ignoresSafeArea()
            } else {
                    Color.red
                        .ignoresSafeArea()
            }
            VStack {
                if isRed {
                    VStack {
                        Spacer()
                        Button(action: {
                            isRed = false
                        }) {
                            Text("Reset")
                                .font(Font.system(size: 40))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                                .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                Spacer()
                
                    if isEditing {
                        HStack {
                            Text("Threshold:")
                            TextField("Threshold", text: $thresholdText)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding()
                    }
                    
                    
                    Button(isEditing ? "Done" : "Edit") {
                        if isEditing {
                            if let threshold = Double(thresholdText) {
                                bluetoothManager.threshold = threshold
                            }
                            isEditing = false
                        } else {
                            thresholdText = "\(bluetoothManager.threshold)"
                            isEditing = true
                        }
                    }
                .padding(.bottom, 20)
                
                Button("Disconnect") {
                    disconnectAction()
                }
            }
        }
        .onReceive(timer) { _ in
            if !isRed && !bluetoothManager.updateVoltageAndAccel(voltage, accel) && ready==true {
                        isRed = true
                    sendNotification()
                    }
            print("red: \(isRed)")
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                ready=true
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
}

class DeviceInfoViewController: UIViewController {

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceUUIDLabel: UILabel!
    @IBOutlet weak var thresholdLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!

    var bluetoothManager: BluetoothManager!
    var peripheral: CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the UI
        deviceNameLabel.text = peripheral.name
        deviceUUIDLabel.text = peripheral.identifier.uuidString
        thresholdLabel.text = String(bluetoothManager.threshold)

        // Set up the edit button
        editButton.setTitle("Edit", for: .normal)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }

    @objc func editButtonTapped() {
        let alertController = UIAlertController(title: "Edit Threshold", message: nil, preferredStyle: .alert)

        let addAction = UIAlertAction(title: "+", style: .default) { [weak self] _ in
            self?.bluetoothManager.threshold += 0.1
            self?.thresholdLabel.text = String(format: "%.1f", self?.bluetoothManager.threshold ?? 0)
        }

        let subtractAction = UIAlertAction(title: "-", style: .default) { [weak self] _ in
            self?.bluetoothManager.threshold -= 0.1
            self?.thresholdLabel.text = String(format: "%.1f", self?.bluetoothManager.threshold ?? 0)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(addAction)
        alertController.addAction(subtractAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}
