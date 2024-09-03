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
    
    @AppStorage("mirrored") private var mirrored: Bool = false
    @AppStorage("crosshairColor") private var crosshairColor: Color = .black
    @AppStorage("crosshairLinewidth") private var crosshairLineWidth: Double = 1.0
    @AppStorage("magnification") private var magnification: Int = 1

    var body: some View {
        GeometryReader { geo in
            let rect: CGRect = geo.frame(in: .local)
            ZStack {
                imageView(rect: rect)
                crosshairView(rect: rect)
                VStack {
                    Spacer()
                    buttonsView()
                        .frame(height: rect.height * 0.05, alignment: .bottom)
                }
            }
        }
        .onAppear {
            Task {
                await model.camera.start()
                model.camera.updateMirroring()
                model.camera.updateMagnification()
            }
        }
    }
    
    func imageView(rect: CGRect) -> some View {
        Group {
            if let image = model.viewfinderImage {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: rect.width, height: rect.height)
            }
        }
    }
    
    func buttonsView() -> some View {
        ZStack {
            Color.black.opacity(0.5)
            HStack {
                Group {
                    Spacer()
                    Button {
                        model.camera.switchCaptureDevice()
                    } label: {
                        Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
                    }
                    Spacer()
                    Button {
                        mirrored = !mirrored
                        model.camera.updateMirroring()
                    } label: {
                        let sfSymbol = "arrowtriangle.right.and.line.vertical.and.arrowtriangle.left"
                        let image = mirrored ? "\(sfSymbol).fill" : sfSymbol
                        Label("Mirroring", systemImage: image)
                    }
                    Spacer()
                    Menu {
                        Button { magnification = 1 }
                            label: { Text("x1") }
                        Button { magnification = 2 }
                            label: { Text("x2") }
                        Button { magnification = 3
                        } label: { Text("x3") }
                    } label: {
                        Label("Magnification", systemImage: "magnifyingglass")
                    }
                    .onChange(of: magnification) { _ in model.camera.updateMagnification()}
                    Spacer()
                }
                Group {
                    Menu {
                        if #available(iOS 15, *) {
                            Section("Color") { doColorButtons() }
                            Divider()
                            Section("Line width") { doWidthButtons() }
                        } else {
                            doColorButtons()
                            Divider()
                            doWidthButtons()
                        }
                    } label: {
                        Label("Crosshair", systemImage: "scope")
                    }
                    Spacer()
                    Button {
                        popover = true
                    } label: {
                        Label("How to use", systemImage: "questionmark.circle")
                    }
                    .popover(isPresented: $popover) {
                        Text("""
                       You should first connect your CNC Mill USB-camera to your Mac and then start CNC Camera. Theoretically you can connect multiple cameras although this is of little use.

                       **Select Camera:** The app will display the built-in camera of your Mac at startup. Use 'Select Camera' to cycle through all cameras until you find the CNC Mill camera.

                       **Mirroring:** A webcam will normally not be mirrored, i.e., the image moves to the left when you move the mill to the right and vice versa. This is confusing and switching on 'Mirroring' will reverse the movement and provide a natural feel.

                       **Magnification:** You can switch magnification to 1x, 2x or 3x.

                       **Crosshair:** You can select the line width of the crosshair as well as the color for maximum contrast with the color of your milling material.

                       """)
                        .foregroundColor(.black)
                        .frame(width: 400)
                        .padding()
                    }
                    Spacer()
                }
            }
        }
        .font(.system(size: 18))
        .foregroundColor(.white)
        .buttonStyle(.plain)
    }
    
    func doColorButtons() -> some View {
        Group {
            Button { crosshairColor = .white } label: { Text("White") }
            Button { crosshairColor = .black } label: { Text("Black") }
            Button { crosshairColor = .red } label: { Text("Red") }
        }
    }
    
    func doWidthButtons() -> some View {
        Group {
            Button { crosshairLineWidth = 0.5 } label: { Text("0.5 pixel") }
            Button { crosshairLineWidth = 1 } label: { Text("1 pixel") }
            Button { crosshairLineWidth = 2 } label: { Text("2 pixels") }
        }
    }
    
    func crosshairView(rect: CGRect) -> some View {
        Path { path in
            let half = CGFloat(150)
            path.move(to: CGPoint(x: rect.midX - half, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX + half, y: rect.midY))
            path.move(to: CGPoint(x: rect.midX, y: rect.midY - half))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY + half))
            path.move(to: CGPoint(x: rect.midX, y: rect.midY))
            path.addArc(
                center: CGPoint(x: rect.midX, y: rect.midY),
                radius: 20,
                startAngle: .degrees(0),
                endAngle: .degrees(360),
                clockwise: false
            )
        }
        .stroke(crosshairColor, lineWidth: CGFloat(crosshairLineWidth))
    }
}
