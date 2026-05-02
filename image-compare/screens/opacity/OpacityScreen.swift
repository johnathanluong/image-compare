//
//  OpacityScreen.swift
//  image-compare
//
//  Created by Johnathan Tuong Luong on 5/2/26.
//

import SwiftUI

struct OpacityScreen : View
{
    @State var opacity : CGFloat = 0.5
    var session : Session
    
    var body : some View
    {
        VStack(spacing: 0)
        {
            ZStack()
            {
                // Image A is background
                ImageView(cg: session.image_a)
                    .imageTransform(session)
                // Image B is foreground that will be blended in
                ImageView(cg: session.image_b)
                    .imageTransform(session)
                    .opacity(opacity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        Slider(value: $opacity, in: 0...1).padding()
    }
}


