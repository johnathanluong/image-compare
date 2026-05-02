//
//  ContentView.swift
//  image-compare
//
//  Created by Johnathan Tuong Luong on 5/1/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var session = Session()
    @State private var is_importing_a = false;
    @State private var is_importing_b = false;
    

    var body: some View
    {
        NavigationStack()
        {
            TabView()
            {
                Tab("Side by Side", systemImage: "square.split.2x1")
                {
                    SideBySideScreen(session: session)
                }
                Tab("Slider", systemImage: "slider.horizontal.below.circle.lefthalf.filled")
                {
                    SliderScreen(session: session)
                }
                Tab("Opacity", systemImage: "circle.lefthalf.filled.righthalf.striped.horizontal.inverse")
                {
                    OpacityScreen(session: session)
                }
                Tab("Difference", systemImage: "minus.square")
                {
                    DiffScreen(session: session)
                }
                Tab("Flicker", systemImage: "lightswitch.off")
                {
                    FlickerScreen(session: session)
                }
            }
            .toolbar {
                ToolbarItem(placement:
                {
                    #if os(iOS)
                    .topBarLeading
                    #else
                    .navigation
                    #endif
                }()) {
                    Button(action: { is_importing_a = true }) {
                        Label("Select Image A", systemImage: "photo.badge.plus")
                    }
                    .labelStyle(.titleAndIcon)
                    .fileImporter(isPresented: $is_importing_a, allowedContentTypes: [.image]) { result in
                        if case .success(let url) = result {
                            session.LoadImageA(url)
                        }
                    }
                }
                ToolbarItem(placement:
                {
                    #if os(iOS)
                    .topBarTrailing
                    #else
                    .primaryAction
                    #endif
                }()) {
                    Button(action: { is_importing_b = true }) {
                        Label("Select Image B", systemImage: "photo.badge.plus")
                    }
                    .labelStyle(.titleAndIcon)
                    .fileImporter(isPresented: $is_importing_b, allowedContentTypes: [.image]) { result in
                        if case .success(let url) = result {
                            session.LoadImageB(url)
                        }
                    }
                }
            }
        }
    }
}
