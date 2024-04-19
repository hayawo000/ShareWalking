//
//  RecordOther.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/24.
//

import SwiftUI

struct OtherRecord : Identifiable{
    var id = UUID()
    var username: String
    var date: String
    var courseName: String
    var stepCount: Int
    var meter: Double
    var walkTime: String
}
