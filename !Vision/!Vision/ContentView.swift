//
//  ContentView.swift
//  !Vision
//
//  Created by Mitesh Mangesh Patil on 14/11/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ObjectRecognitionView()
}
