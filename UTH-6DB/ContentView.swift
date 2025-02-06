//
//  ContentView.swift
//  UTH-6DB
//
//  Created by 이요섭 on 2/6/25.
//

import SwiftUI

struct ContentView: View {
    @State var showSplash: Bool = false
    var body: some View {
        ZStack {
            if self.showSplash {
                MainView()
            } else {
                SplashScreenView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    self.showSplash = true
                }
            }
        }
    }
}

struct MainView: View {
    @ObservedObject var bluetoothManager = BluetoothManager()
    @EnvironmentObject var timerManager: TimeManager
    
    @State private var isShowingModal = false
    @State private var currentDate = Date()
    @State private var buttonActionTriggered = false
    @State private var navigateToLanding = false
    @State private var navigateToScan = false
    // @State private var navigateToSetting = false
    private let videoID = "gWstaniV0Jw"
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
            
        formatter.dateFormat = "yyyy년 M월 d일 EEEE" //
        formatter.locale = Locale(identifier: "ko_KR") // 사용자의 현재 로케일 설정을 사용
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "a hh:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if navigateToLanding {
                    LandingView(bluetoothManager: bluetoothManager, navigateToLanding: $navigateToLanding, powerOnOff: bluetoothManager.powerOnOff)
                } else {
                    Color.bgWhite.ignoresSafeArea()
                    
                    VStack() {
                        Text("Uriel")
                            .font(Font.custom("Pretendard", size: 20).weight(.bold))
                            .foregroundColor(.blackDark)
                        
                        VStack {
                            Text(dateFormatter.string(from: timerManager.currentDate))
                                .font(Font.custom("Pretendard", size: 18).weight(.bold))
                                .foregroundColor(.whiteLight)
                                .onReceive(timer) { _ in
                                    currentDate = Date()
                                }
                                .padding(.top, 8)
                            
                            Text(timeFormatter.string(from: timerManager.currentDate))
                            
                                .font(Font.custom("Pretendard", size: 28).weight(.bold))
                                .lineSpacing(28)
                                .foregroundColor(.whiteLight)
                                .onReceive(timer) { input in
                                    currentDate = input
                                }
                                .padding(.top, 2)
                                .padding(.bottom)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color(red: 0, green: 0.52, blue: 1), Color(red: 0.34, green: 0.76, blue: 1)]), startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(24)
                        .padding()
                        
                        VStack(spacing: 20) {
                            Text("기기 설치 후 아래의 버튼을 눌러\n기기를 연결해주세요.")
                                .font(Font.custom("Pretendard", size: 17).weight(.bold))
                                .lineSpacing(8)
                                .foregroundColor(.blackDark)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                            
                            Button(action : {
                                isShowingModal = true
                            }) {
                                HStack {
                                    Text("기기 연결하기")
                                        .font(Font.custom("Pretendard", size: 18).weight(.bold))
                                }
                                .padding(EdgeInsets(top: 15, leading: 95, bottom:15, trailing: 95))
                                .foregroundColor(.whiteLight)
                                .frame(maxWidth: .infinity)
                                .background(.blackDark)
                                .cornerRadius(12)
                                .padding(.bottom)
                            }
                            .sheet(isPresented: $isShowingModal) {
                                ScanView(bluetoothManager:bluetoothManager, navigateToLanding: $navigateToLanding)
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(.whiteLight)
                        .cornerRadius(24)
                        .padding()
                        .padding(.top, -20)
                        
                        VStack {
                            Text("작동 설명 영상")
                                .font(Font.custom("Pretendard", size: 17).weight(.bold))
                                .foregroundColor(.textLight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                            
                            YouTubeView(videoID: videoID)
                                .cornerRadius(24)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.22, green: 0.23, blue: 0.25))
                        .cornerRadius(24)
                        .padding()
                        .padding(.top, -20)
                        .opacity(0)
                    }
                    .padding(.top, 12)
                }
            }
            .onAppear {
                bluetoothManager.loadPeripheralList()
            }
        }
    }
}

struct SplashScreenView: View {
    var body: some View {
        Color.bgWhite.ignoresSafeArea()
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
            Image("Splash")
                .resizable()
                .frame(width: 140, height: 140)
                .padding(.vertical, 175)
            Image("SplashWord")
                .resizable()
                .frame(width: 120, height: 30)
        }
            
    }
}
