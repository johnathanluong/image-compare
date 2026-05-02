//
//  ImageTransform.swift
//  image-compare
//
//  Created by Johnathan Tuong Luong on 5/2/26.
//

import SwiftUI

struct ImageTransform : ViewModifier {
    var session : Session
    
    func body(content : Content) -> some View
    {
        content
            .scaleEffect(session.scale)
            .offset(session.offset)
            .gesture(
                SimultaneousGesture(
                    // Pinch to zoom
                    MagnifyGesture()
                        .onChanged { value in
                            session.scale = session.last_scale * value.magnification
                        }
                        .onEnded { _ in
                            session.last_scale = session.scale
                        },
                    // Drag to move picture around
                    DragGesture()
                        .onChanged { value in
                            session.offset = CGSize(
                                width: session.last_offset.width + value.translation.width,
                                height: session.last_offset.height + value.translation.height,
                            )
                        }
                        .onEnded { _ in
                            session.last_offset = session.offset
                        }
                )
            )
            // Reset all transforms when double tapping
            .onTapGesture(count: 2)
            {
                withAnimation(.spring)
                {
                    session.ResetTransforms()
                }
            }
    }
}

extension View {
    func imageTransform(_ session: Session) -> some View {
        modifier(ImageTransform(session: session))
    }
}
