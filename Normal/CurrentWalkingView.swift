//
//  CurrentWalkingView.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/22.
//

import SwiftUI

struct CurrentWalkingView: View {
    
    @Binding var showCurrentWalkingView: Bool
    @EnvironmentObject var manager: NormalManager
    
    var body: some View {
        ZStack {
            
            Color(red: 144/255, green: 215/255, blue: 236/255)
                .ignoresSafeArea()
            
            VStack {
                Text("経過時間：" + String(manager.resultTime))
                    .padding()
                    .font(.title)
                    .foregroundColor(.white)
                Text("歩数：" + String(manager.count))
                    .font(.title)
                    .foregroundColor(.white)
                Text("移動距離：" + String(manager.meter ?? 0.0))
                    .padding()
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
    }
}

struct CurrentWalkingView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentWalkingView(showCurrentWalkingView: Binding.constant(false))
    }
}
