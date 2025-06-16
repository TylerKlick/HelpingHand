//
//  MyDeviceView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/16/25.
//

import SwiftUI

struct MyDeviceView: View {
    
    @State private var isConnected: Bool = false
    
    var body: some View {
        VStack {
            if isConnected {
                ConnectedAnimationView()
            } else {
                NotConnectedAnimationView()
            }
            
            Button("Connect")
            {
                isConnected.toggle()
            }
        }
    }
}

#Preview {
    MyDeviceView()
}
