//
//  StripManager.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.08.2023.
//

import Foundation
import CoreImage
import SwiftUI
import FirebaseCrashlytics

class StripColorManager {
    private var stripColorCount: Int
    private var colorMood: ColorMood
    
    init(stripColorCount: Int) {
        self.stripColorCount = stripColorCount
        self.colorMood = ColorMood()
    }
    
    func appendAverageColors(for video: Video, from shotURL: URL?, completion: @escaping (() -> Void) = {}) async {
        guard
            let imageURL = shotURL,
            let ciImage = CIImage(contentsOf: imageURL),
            let cgImage = convertCIImageToCGImage(inputImage: ciImage)
        else {
            completion()
            return
        }
        
        do {
            let cgColors = try await ColorsExtractorService.extract(
                from: cgImage,
                method: colorMood.method,
                count: stripColorCount,
                formula: colorMood.formula,
                quality: colorMood.quality,
                options: colorMood.options
            )
            let colors = cgColors.map({ Color(cgColor: $0) })
            
            DispatchQueue.main.async {
                video.grabColors.append(contentsOf: colors)
                completion()
            }
        } catch let error {
            print(error.localizedDescription)
            Crashlytics.crashlytics().record(error: error, userInfo: ["function": #function, "object": type(of: self)])
            completion()
        }
    }
    
    func getAverageColors(from imageURL: URL) async -> Result<[Color], Error> {
        guard
            let ciImage = CIImage(contentsOf: imageURL),
            let cgImage = convertCIImageToCGImage(inputImage: ciImage)
        else {
            return .failure(StripColorManagerError.imageFailure(url: imageURL))
        }
        
        do {
            let cgColors = try await ColorsExtractorService.extract(
                from: cgImage,
                method: colorMood.method,
                count: stripColorCount,
                formula: colorMood.formula, 
                quality: colorMood.quality,
                options: colorMood.options
            )
            let colors = cgColors.map({ Color(cgColor: $0) })
            
            return .success(colors)
        } catch {
            Crashlytics.crashlytics().record(error: error, userInfo: ["function": #function, "object": type(of: self)])
            return .failure(error)
        }
    }
    
    private func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, from: inputImage.extent)
    }
}
