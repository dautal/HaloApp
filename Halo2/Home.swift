//
//  Home.swift
//  Halo2
//
//  Created by Team 23 Halo on 2/23/23.
//

import SwiftUI


struct HomeView: View {
    @Binding var isConnected: Bool
    @State private var webViewPresented = false
    
    var body: some View {
        VStack {
            Image("IMG_1765")
                .resizable()
                .frame(width: 150, height: 150)
                .padding(.top, 150)
            
            Spacer()
            
            Button(action: {
                isConnected=true
            }) {
                HStack {
                    Image(systemName: "wifi")
                        .font(.title)
                    Text("Connect")
                        .fontWeight(.semibold)
                        .font(.title)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(40)
                .padding(.horizontal, 20)
            }
            .fullScreenCover(isPresented: $isConnected) {
                ContentView()
            }
            
            Spacer()
            
            Button(action: {
                // Define action for Info button
            }) {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.title)
                    Text("Info")
                        .fontWeight(.semibold)
                        .font(.title)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(40)
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            Button(action: {
                guard let url = URL(string: "https://frankwu5.wixsite.com/halo-drink-protector") else { return }
                UIApplication.shared.open(url)
            }) {
                HStack {
                    Image(systemName: "link")
                        .font(.title)
                    Text("Website")
                        .fontWeight(.semibold)
                        .font(.title)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(40)
                .padding(.horizontal, 20)
            }
                
            Spacer()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .font(.custom("Helvetica Neue", size: 16))
    }
}
