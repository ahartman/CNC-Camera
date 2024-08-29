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
    @AppStorage("crosshairColor") private var crosshairColor: Color = .black
    @AppStorage("crosshairLinewidth") private var crosshairLineWidth: Int = 1

    var body: some View {
        GeometryReader { geo in
            let rect: CGRect = geo.frame(in: .local)
            ZStack {
                imageView(geo: geo)
                crosshairView(rect: rect)
                VStack {
                    Spacer()
                    buttonsView()
                        .frame(height: geo.size.height * 0.05, alignment: .bottom)
                }
            }
        }
        .onAppear {
            Task { await model.camera.start() }
        }
        /*
         .task {
             await model.camera.start()
         }
          */
    }

    private func imageView(geo: GeometryProxy) -> some View {
        HStack {
            if let image = model.viewfinderImage {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }

    private func buttonsView() -> some View {
        ZStack {
            Color.black.opacity(0.75)
            HStack {
                Spacer()
                Button {
                    model.camera.switchCaptureDevice()
                } label: {
                    Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
                }
                Spacer()
                Button {
                    model.isMirrored = !model.isMirrored
                    model.camera.updateMirroring()
                } label: {
                    let sfSymbol = "arrowtriangle.right.and.line.vertical.and.arrowtriangle.left"
                    let image = model.isMirrored ? "\(sfSymbol).fill" : sfSymbol
                    Label("Mirror Image", systemImage: image)
                }
                Spacer()
                Menu {
                    // Section("Color") {
                    Button { crosshairColor = .white } label: {
                        Label("White", systemImage: "rectangle.stack.badge.plus.fill")
                    }
                    Button { crosshairColor = .black } label: {
                        Label("Black", systemImage: "rectangle.stack.badge.plus")
                    }
                    Button { crosshairColor = .red } label: {
                        Label("Red", systemImage: "rectangle.stack.badge.plus")
                    }
                    // }
                    Divider()
                    // Section("Line width") {
                    Button { crosshairLineWidth = 1 } label: {
                        Label("1 pixel", systemImage: "rectangle.stack.badge.plus.fill")
                    }
                    Button { crosshairLineWidth = 2 } label: {
                        Label("2 pixels", systemImage: "rectangle.stack.badge.plus")
                    }
                    Button { crosshairLineWidth = 3 } label: {
                        Label("3 pixels", systemImage: "rectangle.stack.badge.plus")
                    }
                    // }
                } label: {
                    Label("Crosshair Settings", systemImage: "scope")
                }
                Spacer()
                Button {
                    popover = true
                } label: {
                    Label("How to use", systemImage: "questionmark.circle")
                }
                .popover(isPresented: $popover) {
                    Text("""
                    Open 'CNC Camera' after connecting one or more USB cameras to your Mac. External cameras usually are not mirrored which is counterintuitive.\n● 'Switch Camera' to cycle through the built-in and connected cameras.\n● 'Mirror Image' to switch on mirroring.\n● 'Crosshair Settings' to set line color and line width.
                    """)
                    .font(.title2)
                    .foregroundColor(.black)
                    .frame(width: 400)
                    .padding()
                }
                Spacer()
            }
        }
        .font(.system(size: 24))
        .foregroundColor(.white)
        .buttonStyle(.plain)
    }

    private func crosshairView(rect: CGRect) -> some View {
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

extension Color: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            self = .black
            return
        }
        do {
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor ?? .black
            self = Color(color)
        } catch {
            self = .black
        }
    }

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
}
