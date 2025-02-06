//
//  ScanView.swift
//  UTH-6DB
//
//  Created by 이요섭 on 1/31/25.
//

import SwiftUI
import CoreBluetooth

struct ScanView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @Environment(\.presentationMode) var presentationMode
    @Binding var navigateToLanding: Bool

    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @State private var showRenamePopup = false
    @State private var newDeviceName = ""
    @State private var selectedDevice: CBPeripheral? = nil
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            Color.bgWhite.ignoresSafeArea()
            VStack {
                if isLoading {
                    Text("기기 연결 중").font(Font.custom("Pretendard", size: 24).weight(.bold)).foregroundColor(.blackDark).padding(.top, 40)
                    
                    ProgressView("연결 중...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blackDark))
                } else if (showRenamePopup) {
                    ZStack {
                        Color.black.opacity(0.3)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        showRenamePopup = false
                                    }
                                }
                            
                            if let device = selectedDevice {
                                VStack {
                                    RenameDevicePopup(device: device, newDeviceName: $newDeviceName, onSave: {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                saveDeviceName(for: device.identifier.uuidString, name: newDeviceName)
                                                showRenamePopup = false
                                            }
                                    })
                                }
                                .frame(width: 300)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(radius: 10)
                                .opacity(showRenamePopup ? 1.0 : 0.0)
                                .transition(.scale)
                            }
                    }
                    .animation(.easeInOut(duration: 0.3), value: showRenamePopup)
                    
                } else {
                    Text("기기 찾기").font(Font.custom("Pretendard", size: 20).weight(.bold)).foregroundColor(.blackDark).padding(.top, 40)
                    Text("기기를 찾지 못할 경우,앱을 종료 후 블루투스 기능을 껏다 켜주세요.").font(Font.custom("Pretendard", size: 15).weight(.bold)).foregroundColor(.blackDark).padding(.vertical, 20)
                    Text("기기 이름을 길게 누르면\n기기 이름을 변경할 수 있습니다.").font(Font.custom("Pretendard", size: 15).weight(.bold)).foregroundColor(.blackDark)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(bluetoothManager.discoveredDevices, id: \.identifier) { device in
                                ZStack {
                                    let deviceName = loadDeviceName(uuidString: device.identifier.uuidString)
                                    let firstDeviceName = bluetoothManager.getLastFourCharacters(for: device)?.lowercased()
                                    let finalName = deviceName ?? firstDeviceName ?? "UTH-6DB"
                                    
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black)
                                    
                                    Text(finalName)
                                        .font(Font.custom("Pretendard", size: 20).weight(.bold))
                                        .foregroundColor(.whiteLight)
                                        .tracking(1)
                                        .padding()
                                }
                                .frame(maxWidth: .infinity)
                                .onTapGesture {
                                    self.isLoading = true
                                    self.bluetoothManager.connectToDevice(device)
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                                        requestPowerData()
                                        requestSettingData()
                                        requestTimeData()
                                        requestDayTimeData()
                                    }
                                }
                                .onLongPressGesture(minimumDuration: 1.0) {
                                    self.selectedDevice = device
                                    self.newDeviceName = loadDeviceName(uuidString: device.identifier.uuidString) ?? ""
                                    self.showRenamePopup = true
                                    print(selectedDevice ?? "No Device Selected")
                                }
                            }
                            //
                        }
                        .padding(.horizontal)
                    }
                    .onAppear {
                        bluetoothManager.loadPeripheralList()
                        bluetoothManager.onConnect = {
                            self.isLoading = false
                            self.navigateToLanding = true
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: showRenamePopup)
                }
            }
        }
    }
    
    
    func saveDeviceName(for uuidString:String, name: String) {
        let keyName = uuidString
        var peripheralDict = UserDefaults.standard.dictionary(forKey: "PeripheralList") as? [String: [String: String]] ?? [:]
        peripheralDict[keyName] = ["name": name]
        
        UserDefaults.standard.set(peripheralDict, forKey: "PeripheralList")
        print(keyName)
    }
    
    func loadDeviceName(uuidString: String) -> String? {
        // let connectedName = bluetoothManager.connectedDeviceIdentifier
        // UserDefaults.standard.string(forKey: connectedName)
        if let peripheralDict = UserDefaults.standard.dictionary(forKey: "PeripheralList") as? [String: [String: String]] {
            return peripheralDict[uuidString]?["name"]
        }
        return nil
    }
    
    func requestPowerData() {
        if !bluetoothManager.bluetoothIsReady {
            print("기기가 연결되지 않음")
            alertMessage = "블루투스가 준비되지 않았습니다."
            showingAlert = true
            return
        }
        
        let CHECKSUM: UInt8 = 175 &+ 1
        
        let packet: [UInt8] = [175, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, CHECKSUM, 13, 10]
        
        print(packet)
        bluetoothManager.sendBytesToDevice(packet)
                
    }
    
    func requestSettingData() {
        if !bluetoothManager.bluetoothIsReady {
            print("기기가 연결되지 않음")
            alertMessage = "블루투스가 준비되지 않았습니다."
            showingAlert = true
            return
        }
        
        let CHECKSUM: UInt8 = 175 &+ 5
        
        let packet: [UInt8] = [175, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, CHECKSUM, 13, 10]
        
        print(packet)
        bluetoothManager.sendBytesToDevice(packet)
    }
    
    func requestTimeData() {
        if !bluetoothManager.bluetoothIsReady {
            print("기기가 연결되지 않음")
            alertMessage = "블루투스가 준비되지 않았습니다."
            showingAlert = true
            return
        }
        
        let CHECKSUM: UInt8 = 175 &+ 10
        
        let packet: [UInt8] = [175, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, CHECKSUM, 13, 10]
        print(packet)
        bluetoothManager.sendBytesToDevice(packet)
        
//        presentationMode.wrappedValue.dismiss()
//        navigateToLanding = true
    }
    
    func requestDayTimeData() {
        if !bluetoothManager.bluetoothIsReady {
            print("기기가 연결되지 않음")
            alertMessage = "블루투스가 준비되지 않았습니다."
            showingAlert = true
            return
        }
        
        let CHECKSUM: UInt8 = 207 &+ 1
        let packet: [UInt8] = [207, 1, 0,0,0,0,0,0,0, 0,0,0,0,0,0,0, 0,0,0,0,0,0,0, 0,0,0,0,0,0,0 ,CHECKSUM, 13, 10]
        
        bluetoothManager.sendBytesToDevice(packet)
        alertMessage = "기기 설정이 완료되었습니다"
        showingAlert = true
        
        presentationMode.wrappedValue.dismiss()
        navigateToLanding = true
    }
}

struct RenameDevicePopup: View {
    let device: CBPeripheral
    @Binding var newDeviceName: String
    var onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("기기 이름 변경")
                .font(.headline)
            
            TextField("새로운 기기 이름", text: $newDeviceName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("저장") {
                onSave()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(12)
            
            Button("취소") {
                onSave()
            }
            .padding()
            .foregroundColor(.red)
        }
        .padding()
    }
}
