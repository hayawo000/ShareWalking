//
//  TopView.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/03.
//

import SwiftUI

struct TopView: View {
    
    @State var showHealthView = false
    @State var showWalkView = false
    
    var body: some View {
        ZStack {
            Color(red: 144/255, green: 215/255, blue: 236/255)
                .ignoresSafeArea()
            
            VStack {
                Text("シェアウォーキング")
                    .fontWeight(.bold)
                    .font(.title)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
            
            VStack {
                
                Button(action: {
                    self.showWalkView = true
                }) {
                    Text("歩く")
                        .font(.title)
                        .padding()
                        .background(Rectangle()
                            .foregroundColor(.white)
                            .cornerRadius(25)
                            .frame(width: 300, height: 80))
                        .padding()
                }
                .foregroundColor(.black)
                .fullScreenCover(isPresented: $showWalkView) {
                    WalkView(showWalkView: $showWalkView)
                }
             
                Button(action: {
                    self.showHealthView = true
                }) {
                    Text("日々の歩数を見る")
                        .font(.title)
                        .padding()
                        .background(Rectangle()
                            .foregroundColor(.white)
                            .cornerRadius(25)
                            .frame(width: 300, height: 80))
                        .padding()
                }
                .foregroundColor(.black)
                .fullScreenCover(isPresented: $showHealthView) {
                    HealthView(showHealthView: $showHealthView)
                }
            }
        }
    }
}


struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
