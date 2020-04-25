//
//  CVPixelBuffer+SimpleDALPlugin.swift
//  SimpleDALPlugin
//
//  Created by 池上涼平 on 2020/04/25.
//  Copyright © 2020 com.seanchas116. All rights reserved.
//

import Foundation

extension CVPixelBuffer {
    static func create(size: CGSize) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ] as [String: Any]

        let error = CVPixelBufferCreate(
            kCFAllocatorSystemDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32BGRA,
            options as CFDictionary,
            &pixelBuffer)

        guard error == noErr else {
            log("CVPixelBufferCreate error: \(error)")
            return nil
        }
        return pixelBuffer
    }

    var width: Int {
        return CVPixelBufferGetWidth(self)
    }
    var height: Int {
        return CVPixelBufferGetHeight(self)
    }

    func modifyWithContext(callback: (CGContext) -> Void) {
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(self)

        let colorSpace = CGColorSpaceCreateDeviceRGB();
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)

        let context = CGContext(
            data: data,
            width: width, height: height, bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)

        if let context = context {
            callback(context)
        }

        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
    }
}
