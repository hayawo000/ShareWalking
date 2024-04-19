//
//  MakingCourseAddView.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/19.
//

import SwiftUI

struct MakingCourseAddView: View {
    
    @EnvironmentObject var manager: MakingCourseManager
    @Binding var showAddView: Bool
    @State var showingCancelAlert = false
    @State var showingErrorAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                
                Color(red: 144/255, green: 215/255, blue: 236/255)
                    .ignoresSafeArea()
                
                VStack {
                    Text("コース名を入力")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    TextField("", text: $manager.courseName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 220)
                        .padding()
                        
                        Button(action: {
                            if manager.courseName.isEmpty {
                                showingErrorAlert = true
                            }
                            else {
                                manager.saveCourseOnfirestore()
                                showAddView = false
                            }
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
                        .padding()
                        .alert("エラー", isPresented: $showingErrorAlert) {
                            Button("了解") {
                            }
                        } message: {
                            Text("コース名を入力してください")
                        }
                }
                .alert("コース作成開始" ,isPresented: $showingCancelAlert) {
                    Button("戻る", role: .cancel) { }
                    Button("取消"){
                        manager.cancelMakingCourse()
                        showAddView = false
                    }
                } message: {
                    Text("コース共有を取り消しますか？")
                }
            }
            .navigationTitle("コースを共有")
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

struct MakingCourseAddView_Previews: PreviewProvider {
    static var previews: some View {
        MakingCourseAddView(showAddView: Binding.constant(false)).environmentObject(MakingCourseManager())
    }
}
