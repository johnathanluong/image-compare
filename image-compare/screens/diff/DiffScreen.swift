//
//  DiffScreen.swift
//  image-compare
//
//  Created by Johnathan Tuong Luong on 5/2/26.
//

import SwiftUI
import CoreImage

enum DiffMode: String, CaseIterable {
    case absolute = "Absolute"
    case signed = "Signed"
    case amplified = "Amplified"
    case threshold = "Threshold"
}

struct DiffScreen: View {
    var session: Session

    @State private var mode: DiffMode = .amplified
    @State private var diff_image: CGImage? = nil
    @State private var threshold : Double = 0.2

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ImageView(cg: session.image_a)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .clipped()
                ImageView(cg: session.image_b)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .clipped()
            }
            .frame(height: 100)
            
            Divider()
            ImageView(cg: diff_image)
                .imageTransform(session)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Divider()

            Picker("Mode", selection: $mode) {
                ForEach(DiffMode.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            if mode == .threshold {
                HStack {
                    Text("Threshold")
                    Slider(value: $threshold, in: 0.0...1.0)
                        .onChange(of: threshold) { recompute() }
                    Text(String(format: "%.0f%%", threshold * 100))
                        .monospacedDigit()
                        .frame(width: 40)
                }
                .padding(.horizontal)
            }
        }
        .onChange(of: session.image_a) { recompute() }
        .onChange(of: session.image_b) { recompute() }
        .onChange(of: mode)           { recompute() }
        .onAppear                     { recompute() }
    }

    private func recompute() {
        guard let a = session.image_a, let b = session.image_b
        else
        {
            diff_image = nil
            return
        }
        
        Task.detached(priority: .userInitiated) {
            let result = await computeDiff(a: a, b: b, mode: mode)
            await MainActor.run { diff_image = result }
        }
    }
}

private func computeDiff(a: CGImage, b: CGImage, mode: DiffMode) -> CGImage? {
    let ci_a = CIImage(cgImage: a)
    let ci_b = CIImage(cgImage: b)
    let context = CIContext()

    let output: CIImage?

    switch mode {
    case .absolute:
        // |A - B|
        let diff = ci_a.applyingFilter("CIDifferenceBlendMode", parameters: [
            kCIInputBackgroundImageKey: ci_b
        ])
        output = diff

    case .signed:
        // (A - B) * 0.5 + 0.5 — remaps [-1,1] to [0,1]
        // good for diffs in lighting
        let diff = ci_a.applyingFilter("CIDifferenceBlendMode", parameters: [
            kCIInputBackgroundImageKey: ci_b
        ])
        output = diff.applyingFilter("CIColorMatrix", parameters: [
            "inputRVector":   CIVector(x: 0.5, y: 0, z: 0, w: 0),
            "inputGVector":   CIVector(x: 0, y: 0.5, z: 0, w: 0),
            "inputBVector":   CIVector(x: 0, y: 0, z: 0.5, w: 0),
            "inputAVector":   CIVector(x: 0, y: 0, z: 0, w: 1),
            "inputBiasVector": CIVector(x: 0.5, y: 0.5, z: 0.5, w: 0)
        ])

    case .amplified:
        // |A - B| * 10
        // brighter absolute diff
        let diff = ci_a.applyingFilter("CIDifferenceBlendMode", parameters: [
            kCIInputBackgroundImageKey: ci_b
        ])
        output = diff.applyingFilter("CIColorMatrix", parameters: [
            "inputRVector":   CIVector(x: 10, y: 0, z: 0, w: 0),
            "inputGVector":   CIVector(x: 0, y: 10, z: 0, w: 0),
            "inputBVector":   CIVector(x: 0, y: 0, z: 10, w: 0),
            "inputAVector":   CIVector(x: 0, y: 0, z: 0, w: 1),
            "inputBiasVector": CIVector(x: 0, y: 0, z: 0, w: 0)
        ])
    case .threshold:
        // |A - B|, then threshold: pixels above threshold = white, below = black
        let diff = ci_a.applyingFilter("CIDifferenceBlendMode", parameters: [
            kCIInputBackgroundImageKey: ci_b
        ])
        output = diff.applyingFilter("CIColorThreshold", parameters: [
            "inputThreshold": threshold
        ])
    }

    guard let output, let result = context.createCGImage(output, from: ci_a.extent) else {
        return nil
    }
    return result
}
