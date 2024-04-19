//
//  WalkView.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/04.
//

import SwiftUI

struct WalkView: View {
    
    @Binding var showWalkView: Bool
    @State var showNormalView = false
    @State var showMakingView = false
    @State var showRecordView = false
    
    @StateObject var normalManager = NormalManager()
    @StateObject var makingManager = MakingCourseManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 144/255, green: 215/255, blue: 236/255)
                    .ignoresSafeArea()
                
                NavigationLink(
                    destination: NormalMapView().environmentObject(normalManager),
                    isActive: $showNormalView,
                    label: {
                        EmptyView()
                    }
                )
                
                NavigationLink(
                    destination: MakingCourseMapView().environmentObject(makingManager),
                    isActive: $showMakingView,
                    label: {
                        EmptyView()
                    }
                )
                
                NavigationLink(
                    destination: RecordView(),
                    isActive: $showRecordView,
                    label: {
                        EmptyView()
                    }
                )
                
                VStack {
                    Button(action: {
                        normalManager.startManager()
                        self.showNormalView = true
                    }) {
                        Text("ノーマルモード")
                            .font(.title)
                            .padding()
                            .background(Rectangle()
                                .foregroundColor(.white)
                                .cornerRadius(25)
                                .frame(width: 300, height: 80))
                            .padding()
                    }
                    .foregroundColor(.black)
                    
                    Button(action: {
                        makingManager.startManager()
                        self.showMakingView = true
                    }) {
                        Text("コース作成モード")
                            .font(.title)
                            .padding()
                            .background(Rectangle()
                                .foregroundColor(.white)
                                .cornerRadius(25)
                                .frame(width: 300, height: 80))
                            .padding()
                    }
                    .foregroundColor(.black)
                    
                }
            }
            .navigationTitle("モード選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.showWalkView = false
                    }) {
                        Text("終了")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.leading, 15)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.showRecordView = true
                    }) {
                        Text("記録")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.trailing, 15)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct WalkView_Previews: PreviewProvider {
    static var previews: some View {
        WalkView(showWalkView: Binding.constant(true))
    }
}
