//
//  LandingView.swift
//  Bench
//
//  Created by 이요섭 on 1/31/25.
//

import SwiftUI
import CoreBluetooth

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.hasPrefix("#") ? hex.index(after: hex.startIndex) : hex.startIndex
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue >> 16) & 0xFF) / 255.0
        let green = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

struct LandingView: View {
    @ObservedObject var bluetoothManager = BluetoothManager()
    @Binding var navigateToLanding: Bool
    @EnvironmentObject var timerManager: TimeManager
    @State private var currentDate = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading: Bool = false
    @State var powerOnOff: Int
    
    @State private var timer: Timer? = nil
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
            
        formatter.dateFormat = "yyyy년 M월 d일 EEEE" //
        formatter.locale = Locale(identifier: "ko_KR") // 사용자의 현재 로케일 설정을 사용
        return formatter
    }
    
    var body: some View {
        ZStack {
            if !navigateToLanding {
                MainView()
            }
            else {
                if bluetoothManager.powerOnOff == 0 {
                    Color.textPale.ignoresSafeArea()
                    
                    ScrollView {
                        VStack() {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                    .font(Font.custom("Pretendard", size: 20).weight(.bold))
                                    .foregroundColor(.textBlack)
                                    .opacity(0)
                                
                                Spacer()
                                
                                Text(loadDeviceName(uuidString: bluetoothManager.connectedDeviceIdentifier) ?? "Uriel")
                                    .font(Font.custom("Pretendard", size: 20).weight(.bold))
                                    .foregroundColor(.textBlack)
                                    .multilineTextAlignment(.center)
                                
                                Spacer()
                                
                                
                                Image(systemName: "gearshape.fill")
                                    .font(Font.custom("Pretendard", size: 20).weight(.bold))
                                    .foregroundColor(.textBlack)
                                    .opacity(0)
                            }
                            .padding()
                            .padding(.top, 10)
                            
                            HStack {
                                VStack {
                                    HStack(spacing: 0) {
                                            Text("전원 꺼짐")
                                                .font(Font.custom("Pretendard", size: 16).weight(.bold))
                                                .foregroundColor(.textPale)
                                            
                                            Spacer()
                                            
                                            Button (action: {
                                                sendOnData()
                                            }) {
                                                HStack(alignment: .center, spacing: 0) {
                                                    HStack(alignment: .center, spacing: 7.14286) {
                                                        Image("fi:power")
                                                        .frame(width: 14, height: 14)
                                                    }
                                                    .padding(20.57143)
                                                    .background(.bgWhite)
                                                    .cornerRadius(22)
                                                }
                                                .padding(.leading, 8)
                                                .padding(.trailing, 60)
                                                .padding(.top, 7.5)
                                                .padding(.bottom, 7.5)
                                                .background(Color(red: 0.13, green: 0.14, blue: 0.15).opacity(0.4))
                                                .cornerRadius(16)
                                            }
                                    }
                                    .padding()
                                    .padding(.horizontal, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.bgWhite)
                                    .cornerRadius(24)
                                    .padding()
                                }
                            }
                            
                        }
                    }
                } else {
                    Color.bgWhite.ignoresSafeArea()
                    ScrollView {
                        VStack() {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                    .font(Font.custom("Pretendard", size: 20).weight(.bold))
                                    .foregroundColor(.whiteLight)
                                    .opacity(0)
                                
                                Spacer()
                                
                                Text(loadDeviceName(uuidString: bluetoothManager.connectedDeviceIdentifier) ?? "Uriel")
                                    .font(Font.custom("Pretendard", size: 20).weight(.bold))
                                    .foregroundColor(.textBlack)
                                    .multilineTextAlignment(.center)
                                
                                Spacer()
                                
                                Image(systemName: "gearshape.fill")
                                    .font(Font.custom("Pretendard", size: 20).weight(.bold))
                                    .foregroundColor(.textBlack)
                            }
                        }
                        .padding()
                        .padding(.top, 10)
                        
                        HStack {
                            VStack {
                                HStack(spacing: 0) {
                                        Text("전원 켜짐")
                                            .font(Font.custom("Pretendard", size: 16).weight(.bold))
                                            .foregroundColor(.textBlack)
                                        
                                        Spacer()
                                        
                                        Button (action: {
                                            sendOffData()
                                        }) {
                                            HStack(alignment: .center, spacing: 0) {
                                                HStack(alignment: .center, spacing: 7.14286) {
                                                    Image("fi_power_green")
                                                    .frame(width: 14, height: 14)
                                                }
                                                .padding(20.57143)
                                                .background(.bgWhite)
                                                .cornerRadius(22)
                                            }
                                            .padding(.leading, 60)
                                            .padding(.trailing, 8)
                                            .padding(.top, 7.5)
                                            .padding(.bottom, 7.5)
                                            .background(
                                                LinearGradient(
                                                            gradient: Gradient(colors: [Color(hex: "#1BC51B"), Color(hex: "#7BDC51")]),
                                                            startPoint: .top,
                                                            endPoint: .bottom
                                                        )
                                            )
                                            .cornerRadius(16)
                                        }
                                }
                                .padding()
                                .padding(.horizontal, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color.bgPaleWhite)
                                .cornerRadius(24)
                                .padding()
                                
                                HStack (spacing: 0) {
                                    Text(dateFormatter.string(from: timerManager.currentDate))
                                        .font(Font.custom("Pretendard", size: 18).weight(.bold))
                                        .foregroundColor(.textBlack)
                                    Spacer()
//
                                }
                                .padding(.horizontal, 6)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                                .padding(.leading, 16)
                                
                                //현재 벤치 및 대기 온도
                                HStack (spacing: 8) {
                                    VStack(spacing: 4) {
                                        Text("현재 의자 온도")
                                            .font(Font.custom("Pretendard", size: 14).weight(.bold))
                                            .foregroundColor(.textPale)
                                        
                                        HStack (spacing: 2) {
                                            Text("겨울")
                                                .font(Font.custom("Pretendard", size: 14).weight(.bold))
                                                .foregroundColor(.text)
                                            
                                        }
                                    }
                                }
                                .padding()
                                
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadDeviceName(uuidString: String) -> String? {
        // let connectedName = bluetoothManager.connectedDeviceIdentifier
        // UserDefaults.standard.string(forKey: connectedName)
        if let peripheralDict = UserDefaults.standard.dictionary(forKey: "PeripheralList") as? [String: [String: String]] {
            return peripheralDict[uuidString]?["name"]
        }
        return nil
    }
    
    func sendOnData() {
        if !bluetoothManager.bluetoothIsReady {
            print("시리얼이 준비되지 않음")
            return
        }
        
        let CHECKSUM: UInt8 = 175 &+ 1
        
        let packet: [UInt8] = [175, 0, 1, 0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, CHECKSUM, 13, 10]
        print(packet)
        bluetoothManager.sendBytesToDevice(packet)
        
    }
    
    func sendOffData() {
        if !bluetoothManager.bluetoothIsReady {
            print("시리얼이 준비되지 않음")
            return
        }
        
        let CHECKSUM: UInt8 = 175
        
        let packet: [UInt8] = [175, 0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,CHECKSUM, 13, 10]
        print(packet)
        bluetoothManager.sendBytesToDevice(packet)
    }
}
