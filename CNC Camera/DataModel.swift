//
//  DataModel.swift
//  CNC Camera
//
//  Created by André Hartman on 14/08/2024.
//
/*
 See the License.txt file for this sample’s licensing information.
 */

import AVFoundation
import os.log
import SwiftUI

final class DataModel: ObservableObject {
    @Published var viewfinderImage: Image?
    @Published var isMirrored: Bool {
        didSet {
            defaults.set(isMirrored, forKey: "isMirrored")
        }
    }
    let camera = Camera()

    init() {
        isMirrored = defaults.bool(forKey: "isMirrored")
        Task {
            await handleCameraPreviews()
        }
    }

    func handleCameraPreviews() async {
        let imageStream = camera.previewStream
            .map { $0.image }

        for await image in imageStream {
            Task { @MainActor in
                viewfinderImage = image
            }
        }
    }
}

private extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

private let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "DataModel")
