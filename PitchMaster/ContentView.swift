//
//  ContentView.swift
//  Time
//
//  Created by Lixing Liu on 6/14/23.
//

import SwiftUI

struct ContentView: View {
    @State private var settingsButtonTapped: Bool = false
    @EnvironmentObject private var settings: Settings
    
    
        
    var body: some View {
        NavigationView {
            VStack() {
                NavigationLink(destination: SonglistView().environmentObject(settings)) {
                    Text("Practice a song")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
                
                NavigationLink(destination: FreeSingView().environmentObject(settings)) {
                    Text("Free Singing")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
