//
//  RectangleView.swift
//  !Vision
//
//  Created by Mitesh Mangesh Patil on 21/11/23.
//

import SwiftUI

struct RectangleView: View {
    @Binding var detectedObjects: [String]

    var body: some View {
        Rectangle()
            .frame(width: 360, height: 50)
            .foregroundColor(.white)
            .overlay(
                HStack {
                    if !detectedObjects.isEmpty {
                        Text("OBJECT : ")
                            .font(.custom("NewYorkLarge-Medium", size: 18).bold())
                            .foregroundColor(.black)
                            .padding(.leading)
                            

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(detectedObjects, id: \.self) { object in
                                    Text(object)
                                        .textCase(.uppercase)
                                        .font(.custom("NewYorkLarge-Medium", size: 18).bold())
                                        .frame(width: 240, height: 40)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                        .padding(.horizontal, 4)
                                }
                            }
                        }
                    } else {
                        Text("No objects detected")
                            .font(.custom("NewYorkLarge-Medium", size: 18).bold())
                            .foregroundColor(.black)
                            .padding(.leading)
                    }
                }
            )
            .cornerRadius(10)
            .padding(8)
            .shadow(radius: 5)
    }
}

#Preview {
    ObjectRecognitionView()
}
