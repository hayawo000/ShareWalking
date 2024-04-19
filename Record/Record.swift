//
//  Record.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/23.
//

import SwiftUI

struct Record: Identifiable{
    var id: String
    var date: String
    var courseName: String
    var stepCount: Int
    var meter: Double
    var walkTime: String
}
