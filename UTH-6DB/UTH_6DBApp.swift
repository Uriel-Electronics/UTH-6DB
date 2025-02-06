//
//  UTH_6DBApp.swift
//  UTH-6DB
//
//  Created by 이요섭 on 2/6/25.
//

import SwiftUI

@main
struct UTH_6DBApp: App {
    var timerManager = TimeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerManager)
        }
    }
}
