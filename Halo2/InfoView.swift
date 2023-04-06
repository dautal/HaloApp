//
//  InfoView.swift
//  Halo2
//
//  Created by Team 23 Halo on 3/30/23.
//

import SwiftUI

struct InfoView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Text("This is the info view")
            .navigationBarTitle("Info")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Dismiss the view when the Home button is tapped
                }) {
                    Image(systemName: "house.fill")
                        .font(.title)
                }
            )
    }
}
