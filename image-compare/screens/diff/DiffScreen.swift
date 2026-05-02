//
//  DiffScreen.swift
//  image-compare
//
//  Created by Johnathan Tuong Luong on 5/2/26.
//

import SwiftUI
import CoreImage

enum DiffMode: String, CaseIterable {
    case absolute   = "Absolute"
    case signed     = "Signed"
    case amplified  = "Amplified"
}

struct DiffScreen: View {
    var session: Session

    @State private var mode: DiffMode = .amplified
    @State private var diff_image: CGImage? = nil

    var body: some View {
        HStack {
            VStack() {
                ImageView(cg: session.image_a)
                ImageView(cg: session.image_b)
            }

            Picker("Mode", selection: $mode) {
                ForEach(DiffMode.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            ImageView(cg: diff_image)
                .imageTransform(session)
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
    }

    guard let output, let result = context.createCGImage(output, from: ci_a.extent) else {
        return nil
    }
    return result
}
