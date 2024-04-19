//
//  RecordList.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/23.
//

import SwiftUI

struct RecordList: View {
    
    @StateObject var model = RecordModel()
    
    var body: some View {
        VStack {
            List (model.list) { item in
                VStack(alignment: .leading) {
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

struct RecordList_Previews: PreviewProvider {
    static var previews: some View {
        RecordList()
    }
}
