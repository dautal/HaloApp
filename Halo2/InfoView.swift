//
//  InfoView.swift
//  Halo2
//
//  Created by Team 23 Halo on 3/30/23.
//

import SwiftUI
import AVKit

struct InfoView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let videoURL: URL? = Bundle.main.url(forResource: "halovid", withExtension: "mov")

    var body: some View {
        ScrollView {
            VStack {
                Text("Video Demo")
                    .font(.title)
                    .padding(.top, 20)
                if let url = videoURL {
                    VideoPlayer(player: AVPlayer(url: url))
                        .aspectRatio(16/9, contentMode: .fit)
                        .frame(height: 450)
                        .padding(.top, -70)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Text("Video not found")
                }
                Text("How to use:")
                    .font(.headline)
                    .padding(.top, -65)
                
                Text("• The Halo Smart Drink Protector uses two CR2023 3V lithium batteries to operate. Load two batteries into the battery cover located on the top of the device.\n • To protect the drink, simply unwrap the cloth of the protector, stretch the elastic band of cloth, and cover the cup.\n • Turn on the power switch located at the top of the protector. The processor in the protector will then send Bluetooth signals to the user’s cell phone. \n • The name of the protector will soon appear on the Bluetooth device list inside the application. Simply connect the device to the user’s phone by tapping its name.\n • The protector will then detect any attempt to open the protector. When one tries to lift the cloth of the protector, the strain gauge on the elastic band of the cloth senses the change and alerts the user. \n • The protector detects any kind of action that includes the removal of the cloth. However, actions such as pressing on the cover, tapping the cup, or moving the cup will not send out an alert.\n • When not using, turn off the power switch and simply wrap the protector with its cloth and carry it in your bag or in your pocket.")
                    //.multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.top, -25)
            }
            .navigationBarTitle("Product Information")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "house.fill")
                        .font(.title)
                }
            )
        }
    }
}
