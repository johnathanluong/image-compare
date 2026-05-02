//
//  ImageView.swift
//  image-compare
//
//  Created by Johnathan Tuong Luong on 5/2/26.
//

import SwiftUI

struct ImageView : View
{
    var cg : CGImage?
    var background : Color = .clear
    
    var body : some View
    {
        if let cg
        {
            Image(decorative: cg, scale: 1.0)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .background(background)
        }
        else
        {
            Color.clear
        }

    }
}
