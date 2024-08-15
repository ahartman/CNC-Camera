//
//  CameraApp.swift
//  CNC Camera
//
//  Created by André Hartman on 14/08/2024.
//


import SwiftUI
let defaults = UserDefaults.standard

@main
struct CameraApp: App {
    init() {
         if defaults.object(forKey: "isMirrored") == nil {
            defaults.set(true, forKey: "isMirrored")
        }
    }

    var body: some Scene {
        WindowGroup {
            CameraView()
        }
    }
}
