//
//  SideBySideScreen.swift
//  image-compare
//
//  Created by Johnathan Tuong Luong on 5/1/26.
//

import SwiftUI

struct SideBySideScreen : View
{
    @State var session : Session
    var body : some View
    {
        HStack(spacing: 0)
        {
            ImageView(cg: session.image_a)
            Divider()
            ImageView(cg: session.image_b)
        }
        .ignoresSafeArea()
    }
}


