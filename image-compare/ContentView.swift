//
//  ContentView.swift
//  image-compare
//
//  Created by Johnathan Tuong Luong on 5/1/26.
//

import SwiftUI
import PhotosUI

enum Slot { case a; case b }
struct ContentView: View {
    @State private var session = Session()
    @State private var is_file_selecting_a = false;
    @State private var is_file_selecting_b = false;
    @State private var is_photo_selecting_a = false;
    @State private var is_photo_selecting_b = false;
    @State private var is_showing_source_picker_a = false;
    @State private var is_showing_source_picker_b = false;
    @State private var selected_photo_a: PhotosPickerItem? = nil
    @State private var selected_photo_b: PhotosPickerItem? = nil

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
                    Button(action: { is_showing_source_picker_a = true }) {
                        Label("Select Image A", systemImage: "photo.badge.plus")
                    }
                    .labelStyle(.titleAndIcon)
                    .confirmationDialog("Select Image A", isPresented: $is_showing_source_picker_a)
                    {
                        Button("Files")
                        {
                            is_file_selecting_a = true
                        }
                        Button("Photos")
                        {
                            is_photo_selecting_a = true
                        }
                    }
                    .fileImporter(isPresented: $is_file_selecting_a, allowedContentTypes: [.image]) { result in
                        if case .success(let url) = result {
                            session.LoadImageA(url)
                        }
                    }
                    .photosPicker(isPresented: $is_photo_selecting_a, selection: $selected_photo_a, matching: .images)
                }
                ToolbarItem(placement:
                {
                    #if os(iOS)
                    .topBarTrailing
                    #else
                    .primaryAction
                    #endif
                }()) {
                    Button(action: { is_showing_source_picker_b = true }) {
                        Label("Select Image B", systemImage: "photo.badge.plus")
                    }
                    .labelStyle(.titleAndIcon)
                    .confirmationDialog("Select Image B", isPresented: $is_showing_source_picker_b)
                    {
                        Button("Files")
                        {
                            is_file_selecting_b = true
                        }
                        Button("Photos")
                        {
                            is_photo_selecting_b = true
                        }
                    }
                    .fileImporter(isPresented: $is_file_selecting_b, allowedContentTypes: [.image]) { result in
                        if case .success(let url) = result {
                            session.LoadImageB(url)
                        }
                    }
                    .photosPicker(isPresented: $is_photo_selecting_b, selection: $selected_photo_b, matching: .images)
                }
            }
        }
        .onChange(of: selected_photo_a) {
            LoadPhoto(selected_photo_a, into: .a)
        }
        .onChange(of: selected_photo_b) {
            LoadPhoto(selected_photo_b, into: .b)
        }
    }
    
    private func LoadPhoto(_ item: PhotosPickerItem?, into slot: Slot) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let cg = DataToCG(data) {
                await MainActor.run {
                    switch slot {
                    case .a: session.image_a = cg
                    case .b: session.image_b = cg
                    }
                }
            }
        }
    }

    private func DataToCG(_ data: Data) -> CGImage? {
        #if os(macOS)
        return NSImage(data: data)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        #else
        return UIImage(data: data)?.cgImage
        #endif
    }
}
