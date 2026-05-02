//
//  SideBySideScreen.swift
//  image-compare
//
//  Created by Johnathan Tuong Luong on 5/1/26.
//

import SwiftUI

struct SideBySideScreen : View
{
    var body : some View
    {
        let item = Item(timestamp: Date())
        Text("Created at: \(item.timestamp.formatted())")
    }
}
