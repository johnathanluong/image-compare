//
//  SliderScreen.swift
//  image-compare
//
//  Created by Johnathan Tuong Luong on 5/1/26.
//

import SwiftUI

struct SliderScreen : View
{
    @State var session : Session
    @State var split : CGFloat = 0.5
    
    var body : some View
    {
        GeometryReader
        { geo in
            ZStack(alignment: .leading)
            {
                // Image A
                ImageView(cg: session.image_a)
                
                // Clip off Image B
                ImageView(cg: session.image_b)
                    .clipShape(Rectangle().offset(x: -(geo.size.width * (1 - split))))
                
                // Divider line
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 1)
                    .offset(x: geo.size.width * split - 1)

                // Handle
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .overlay {
                        HStack(spacing: 2) {
                            Image(systemName: "chevron.left")
                            Image(systemName: "chevron.right")
                        }
                        .font(.caption.bold())
                        .foregroundStyle(.black)
                    }
                    .offset(x: geo.size.width * split - 10)
                    .gesture(
                        DragGesture()
                            .onChanged
                            { value in
                                let newFraction = value.location.x / geo.size.width
                                split = min(max(newFraction, 0), 1)
                            }
                    )
            
            }
        }
        .ignoresSafeArea()
    }
}
