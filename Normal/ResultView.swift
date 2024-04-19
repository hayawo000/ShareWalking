//
//  ResultView.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/23.
//

import SwiftUI

struct ResultView: View {
    
    @EnvironmentObject var manager: NormalManager
    @State var showingCancelAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                
                Color(red: 144/255, green: 215/255, blue: 236/255)
                    .ignoresSafeArea()
                
                VStack {
                    /*
                    Text("活動時間：" + String(manager.resultTime))
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
                     */
                    
                    Text("活動時間：59:08" )
                        .padding()
                        .font(.title)
                        .foregroundColor(.white)
                    Text("歩数：6137")
                        .font(.title)
                        .foregroundColor(.white)
                    Text("移動距離：4135.8")
                        .padding()
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        manager.saveResultOnfirestore()
                    }) {
                        Text("共有")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle()
                                .foregroundColor(Color("AppColor"))
                                .frame(width: 100, height: 100))
                            .padding()
                    }
                }
                .alert("活動結果の取消" ,isPresented: $showingCancelAlert) {
                    Button("戻る", role: .cancel) { }
                    Button("取消"){
                        manager.reset()
                    }
                } message: {
                    Text("活動結果は保存されません．よろしいですか？")
                }
            }
            .navigationBarTitle("活動結果")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            showingCancelAlert = true
                        }) {
                            Text("取消")
                        }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView().environmentObject(NormalManager())
    }
}
