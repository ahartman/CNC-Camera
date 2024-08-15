//
//  CameraView.swift
//  CNC Camera
//
//  Created by André Hartman on 14/08/2024.
//

import SwiftUI

struct CameraView: View {
    @ObservedObject private var model = DataModel()
    @State private var popover = false

    var body: some View {
        GeometryReader { geo in
            let rect: CGRect = geo.frame(in: .local)
            GeometryReader { geometry in
                if let image = model.viewfinderImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .overlay(alignment: .bottom) {
                buttonsView()
                    .frame(height: geo.size.height * 0.05)
                    .background(.black.opacity(0.75))
            }
            .overlay(alignment: .center) {
                Path { path in
                    path.move(to: CGPoint(x: rect.midX - 100, y: rect.midY))
                    path.addLine(to: CGPoint(x: rect.midX + 100, y: rect.midY))
                    path.move(to: CGPoint(x: rect.midX, y: rect.midY - 100))
                    path.addLine(to: CGPoint(x: rect.midX, y: rect.midY + 100))
                    path.addArc(
                        center: CGPoint(x: rect.midX, y: rect.midY),
                        radius: 20,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360),
                        clockwise: false
                    )
                }
                .stroke(.white, lineWidth: 1)
            }
        }
        .task {
            await model.camera.start()
        }
    }

    private func buttonsView() -> some View {
        HStack {
            Spacer()
            Button {
                model.camera.switchCaptureDevice()
            } label: {
                Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
            }
            Spacer()
            Toggle(isOn: $model.isMirrored) {
                let sfSymbol = "arrowtriangle.right.and.line.vertical.and.arrowtriangle.left"
                let image = model.isMirrored ? "\(sfSymbol).fill" : sfSymbol
                Label("Mirror Image", systemImage: image)
            }
            .toggleStyle(.button)
            .onChange(of: model.isMirrored) { _ in
                model.camera.updateMirroring()
            }
            Spacer()
            Button {
                popover = true
            } label: {
                Label("How to use", systemImage: "questionmark.circle")
            }
            .popover(isPresented: $popover) {
                Text("""
                Connect one or more USB cameras to your Mac.\nAfter that, open CNC Camera and use the button 'Select camera' to cycle through the built-in and connected cameras.\nExternal cameras usually are not mirrored which is counterintuitve. Use 'Mirror Image' to switch on mirroring; this setting is saved.
                """)
                .font(.title2)
                .foregroundStyle(.black)
                .frame(width: 300)
                .padding()
            }
            Spacer()
        }
        .font(.system(size: 24))
        .foregroundColor(.white)
        .buttonStyle(.plain)
        .padding()
    }
}
