//
//  UserResistrationView.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/23.
//

import SwiftUI
import Firebase

struct UserResistrationView: View {
    
    @AppStorage("username") var username = ""
    @State var name = ""
    @State var showingErrorAlert = false
    @State var showingSamenameAlert = false
    @Binding var noResistered: Bool
    let db = Firestore.firestore()
    
    var body: some View {
        ZStack {
            
            Color(red: 144/255, green: 215/255, blue: 236/255)
                .ignoresSafeArea()
            
            VStack {
                Text("ニックネーム入力")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                TextField("", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 220)
                    .padding()
                
                Button(action: {
                    if !name.isEmpty {
                        judgeSameName()
                    }
                    else {
                        showingErrorAlert = true
                    }
                }) {
                    Text("登録")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle()
                            .foregroundColor(Color("AppColor"))
                            .frame(width: 100, height: 100))
                        .padding()
                }
                .alert("エラー", isPresented: $showingErrorAlert) {
                    Button("了解") {
                    }
                } message: {
                    Text("ニックネームを入力してください")
                }
                .alert("エラー", isPresented: $showingSamenameAlert) {
                    Button("了解") {
                    }
                } message: {
                    Text("既に同じ名前が登録されています．")
                }
                
            }
        }
    }
    
    func judgeSameName() {
        db.collection("users").whereField("name", isEqualTo: name).getDocuments { snapshot, error in
            if error == nil {
            
                if let snapshot = snapshot {
                    
                    DispatchQueue.main.async {
                        if snapshot.isEmpty {
                            self.username = name
                            self.noResistered = false
                            resisterUser()
                        }
                        else {
                            self.showingSamenameAlert = true
                        }
                    }
                }
            }
            else {
                
            }
        }
    }
    
    func resisterUser() {
        db.collection("users").addDocument(data: ["name": self.username]) { error in
            
            if error == nil {
                print("成功しました")
            }
            else {
                print("失敗しました．")
            }
        }
    }
    
}

struct UserResistrationView_Previews: PreviewProvider {
    static var previews: some View {
        UserResistrationView(noResistered: Binding.constant(false))
    }
}
