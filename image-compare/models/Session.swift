//
//  Session.swift
//  image-compare
//
//  Created by Johnathan Tuong Luong on 5/1/26.
//

import Observation
import SwiftUI

@Observable
class Session {
    var image_a: CGImage?
    var image_b: CGImage?

    private var security_scoped_a: URL?
    private var security_scoped_b: URL?

    func LoadImageA(_ url: URL) {
        security_scoped_a?.stopAccessingSecurityScopedResource()
        guard url.startAccessingSecurityScopedResource() else { return }
        security_scoped_a = url
        #if os(iOS)
        image_a = UIImage(contentsOfFile: url.path())?.cgImage
        #else
        image_a = NSImage(contentsOf: url)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        #endif
    }

    func LoadImageB(_ url: URL) {
        security_scoped_b?.stopAccessingSecurityScopedResource()
        guard url.startAccessingSecurityScopedResource() else { return }
        security_scoped_b = url
        #if os(iOS)
        image_b = UIImage(contentsOfFile: url.path())?.cgImage
        #else
        image_b = NSImage(contentsOf: url)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        #endif
    }

    deinit {
        security_scoped_a?.stopAccessingSecurityScopedResource()
        security_scoped_b?.stopAccessingSecurityScopedResource()
    }
}
