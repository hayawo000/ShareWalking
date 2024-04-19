//
//  NormalMapView.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/18.
//

import SwiftUI
import MapKit

struct NormalMapView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var manager: NormalManager
    @State var trackingMode = MapUserTrackingMode.follow
    @State var showSelectCourseView = false
    @State var showCurrentWalkingView = false
    @State var showingCourseErrorAlert = false
    @State var showingStartErrorAlert = false
    @State var showingExplanation = false
    @State var showingStartAlert = false
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $manager.averageRegion,
                showsUserLocation: true,
                userTrackingMode: $trackingMode,
                annotationItems: manager.walkingCourse,
                annotationContent: { spot in MapAnnotation(coordinate: spot.coordinate, content: {
                if spot.isKeyPoint {
                    VStack {
                        Text(spot.pointName)
                            .foregroundColor(spot.isChecked ? .green : nil)
                        
                        Image(systemName: "mappin.and.ellipse")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(spot.isChecked ? .green : .black)
                    }
                    .offset(y: -35)
                }
                else {
                    Circle()
                        .foregroundColor(.red)
                        .frame(width: 10, height: 10)
                }
            })}).ignoresSafeArea()
            
            HStack {
                Button(action: {
                    showSelectCourseView = true
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(Color("AppColor"))
                            .frame(width: 100, height: 100)
                        
                        VStack {
                            Text("コース")
                                .font(.body)
                                .foregroundColor(.white)
                            Text("選択")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Circle()
                            .foregroundColor(Color("AppColor"))
                            .frame(width: 100, height: 100))
                    .padding()
                    }
                }
                .disabled(manager.isWalking)
                .fullScreenCover(isPresented: $showSelectCourseView) {
                    SelectCourseView(showSelectCourseView: $showSelectCourseView)
                        .environmentObject(manager)
                }
                
                Button(action: {
                    if !manager.walkingCourse.isEmpty {
                        if manager.canStart {
                            showingStartAlert = true
                        }
                        else {
                            showingStartErrorAlert = true
                        }
                    }
                    else {
                        showingCourseErrorAlert = true
                    }
                }) {
                    Text("開始")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle()
                            .foregroundColor(Color("AppColor"))
                            .frame(width: 100, height: 100))
                        .padding()
                }
                .disabled(manager.isWalking)
                .alert("ウォーキング開始" ,isPresented: $showingStartAlert) {
                    Button("キャンセル", role: .cancel) { }
                    Button("開始"){
                        manager.startWalking()
                    }
                } message: {
                    Text("ウォーキングを開始しますか？")
                }
                .alert("エラー", isPresented: $showingCourseErrorAlert) {
                    Button("了解") {
                    }
                } message: {
                    Text("コースが選択されていません")
                }
                .alert("エラー", isPresented: $showingStartErrorAlert) {
                    Button("了解") {
                    }
                } message: {
                    Text("スタート地点から離れています")
                }
                
                Button(action: {
                    if !manager.isWalking {
                        self.showingExplanation = true
                    }
                    else {
                        manager.endTime = Date()
                        manager.calcResultTime()
                        showCurrentWalkingView = true
                    }
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(Color("AppColor"))
                            .frame(width: 100, height: 100)
                        
                        Text("情報閲覧")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle()
                                .foregroundColor(Color("AppColor"))
                                .frame(width: 100, height: 100))
                            .padding()
                    }
                }
                .alert("情報閲覧", isPresented: $showingExplanation) {
                    Button("了解") {
                    }
                } message: {
                    Text("ウォーキング中に押すと、その時点での活動情報を閲覧できます。")
                }
                .sheet(isPresented: $showCurrentWalkingView) {
                    CurrentWalkingView(showCurrentWalkingView: $showCurrentWalkingView)
                }
                
            }
            .fullScreenCover(isPresented: $manager.isEndWalking) {
                ResultView()
                    .environmentObject(manager)
            }
        }
        .navigationTitle(manager.testFirestore.name.isEmpty ? "コースを選択してください": manager.testFirestore.name)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    action: {
                        manager.stopManager()
                        dismiss()
                    }) {
                        Text("終了")
                    }
                    .disabled(manager.isWalking)
            }
        }
    }
}

struct NormalMapView_Previews: PreviewProvider {
    static var previews: some View {
        NormalMapView().environmentObject(NormalManager())
    }
}
