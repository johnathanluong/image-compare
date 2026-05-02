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
    var image_a: URL?
    var image_b: URL?

    private var security_scoped_a: URL?
    private var security_scoped_b: URL?

    func LoadImageA(_ url: URL) {
        security_scoped_a?.stopAccessingSecurityScopedResource()
        guard url.startAccessingSecurityScopedResource() else { return }
        security_scoped_a = url
        image_a = url
    }

    func LoadImageB(_ url: URL) {
        security_scoped_b?.stopAccessingSecurityScopedResource()
        guard url.startAccessingSecurityScopedResource() else { return }
        security_scoped_b = url
        image_b = url
    }

    deinit {
        security_scoped_a?.stopAccessingSecurityScopedResource()
        security_scoped_b?.stopAccessingSecurityScopedResource()
    }
}
