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
         if defaults.object(forKey: "mirrored") == nil {
            defaults.set(true, forKey: "mirrored")
        }
    }

    var body: some Scene {
        WindowGroup {
            CameraView()
        }
    }
}
