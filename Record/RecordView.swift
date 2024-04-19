//
//  RecordView.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/23.
//

import SwiftUI

struct RecordView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var select = 0
    let username = UserDefaults.standard.string(forKey: "username") ?? ""
    
    var body: some View {
        ZStack {
            Color(red: 144/255, green: 215/255, blue: 236/255)
                .ignoresSafeArea()
            VStack {
                Picker(selection: $select, label: Text("Select")) {
                    Text("自分").tag(0)
                    Text("他ユーザー").tag(1)
                }
                .padding()
                .pickerStyle(.segmented)
                if select == 0 {
                    RecordList()
                }
                else {
                    OtherRecordList()
                }
                Spacer()
            }
        }
        .navigationTitle(select == 0 ? username + "の記録" : "他ユーザーの記録")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    action: {
                        dismiss()
                    }) {
                        Text("終了")
                            .foregroundColor(.white)
                    }
            }
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView()
    }
}
