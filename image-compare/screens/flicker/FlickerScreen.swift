//
//  FlickerScreen.swift
//  image-compare
//
//  Created by Johnathan Tuong Luong on 5/2/26.
//

import SwiftUI

struct FlickerScreen : View
{
    @State var is_playing = false
    @State var showing_img_a = true
    @State var frequency : Double = 2.5
    @State var timer : Timer? = nil
    var session : Session
    
    var body : some View
    {
        VStack
        {
            ZStack
            {
                // Flicker between img_a and img_b with given frequency
                ImageView(cg: showing_img_a ? session.image_a : session.image_b)
                    .imageTransform(session)
            }
            .frame(maxHeight: .infinity)
            HStack
            {
                Button(action: TogglePlayback)
                {
                    Image(systemName: is_playing ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
                
                Slider(value: $frequency, in: 0.5...16, step: 0.5)
                
                Text(String(format: "%.1f Hz", frequency))
                    .monospacedDigit()
                    .frame(width: 50)
            }
            .padding()
        }
        .onChange(of: frequency)
        {
            if(is_playing)
            {
                StartFlicker()
            }
        }
        .onDisappear()
        {
            StopFlicker()
            is_playing = false
        }
    }
    
    private func TogglePlayback()
    {
        is_playing ? StopFlicker() : StartFlicker()
        is_playing.toggle()
    }
    
    private func StartFlicker()
    {
        StopFlicker()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / frequency, repeats: true, block: { _ in
            showing_img_a.toggle()
        })
    }
    
    private func StopFlicker()
    {
        timer?.invalidate()
        timer = nil
    }
}

