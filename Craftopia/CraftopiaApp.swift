//
//  CraftopiaApp.swift
//  Craftopia
//
//  Created by Yehor Ustenko on 02.08.25.
//

import SwiftUI

@main
struct CraftopiaApp: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
