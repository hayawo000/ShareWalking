//
//  OtherRecordList.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/24.
//

import SwiftUI

struct OtherRecordList: View {
    
    @StateObject var model = OtherRecordModel()
    
    var body: some View {
        VStack {
            List (model.list) { item in
                VStack(alignment: .leading) {
                    Text("ユーザー名：" + item.username)
                    Text("活動日：" + item.date)
                    Text("コース：" + item.courseName)
                    Text("歩数：" + String(item.stepCount) + "歩")
                    Text("移動距離：" + String(item.meter) + "m")
                    Text("活動時間：" + item.walkTime)
                }
            }
        }
    }
}

struct OtherRecordList_Previews: PreviewProvider {
    static var previews: some View {
        OtherRecordList()
    }
}
