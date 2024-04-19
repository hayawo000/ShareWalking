//
//  SelectCourseView.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/20.
//

import SwiftUI
import Firebase

struct SelectCourseView: View {
    
    @Binding var showSelectCourseView: Bool
    @EnvironmentObject var manager: NormalManager
    @StateObject var model = SelectCourseModel()
    let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            ZStack {
                
                Color(red: 144/255, green: 215/255, blue: 236/255)
                    .ignoresSafeArea()
                
                List (model.list) { item in
                    Button(item.name) {
                        manager.loadPointFromFirestore(documentID: item.id)
                        showSelectCourseView = false
                    }
                }
            }
            .navigationTitle("コース選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            showSelectCourseView = false
                        }) {
                            Text("終了")
                        }
                }
            }
        }
    }
}

struct SelectCourseView_Previews: PreviewProvider {
    static var previews: some View {
        SelectCourseView(showSelectCourseView: Binding.constant(false))
            .environmentObject(NormalManager())
    }
}
