//
//  ShareWalkingApp.swift
//  ShareWalking
//
//  Created by 小田敏人 on 2022/09/28.
//

import SwiftUI
import Firebase

@main
struct HealthWalkingApp: App {
    
    @AppStorage("noResistered") var noResistered = true
    
    init() {
        let coloredNavAppearance = UINavigationBarAppearance()
        coloredNavAppearance.configureWithOpaqueBackground()
        coloredNavAppearance.backgroundColor = UIColor.init(red: 0, green:207/255, blue: 180/255, alpha: 1.0)
        coloredNavAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance
        UITableView.appearance().backgroundColor = .clear
        
        FirebaseApp.configure()
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .fullScreenCover(isPresented: $noResistered) {
                    UserResistrationView(noResistered: $noResistered)
                }
        }
    }
}

