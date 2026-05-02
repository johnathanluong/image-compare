//
//  SliderScreen.swift
//  image-compare
//
//  Created by Johnathan Tuong Luong on 5/1/26.
//

import SwiftUI

struct SliderScreen : View
{
    var body : some View
    {
        let item = Item(timestamp: Date())
        Text("Created at: \(item.timestamp.formatted())")
        Text("Anotherone at: \(item.timestamp.formatted())")
    }
}
