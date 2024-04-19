//
//  HealthModel.swift
//  HealthKitSample
//
//  Created by 小田敏人 on 2022/06/01.
//

import Foundation
import HealthKit

class HealthManager: ObservableObject, Identifiable {
    @Published var sampleArray:[Int] = []
    @Published var sumWalking: Int = 0
    var sampleArray2 : [Int] = []
    let healthStore = HKHealthStore()
    let allTypes = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!])
    
    func get(fromDate: Date, toDate: Date) {
        sampleArray = []
        sampleArray2 = []
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore.requestAuthorization(toShare: nil, read: self.allTypes) { (success, error) in
                
                let predicate = HKQuery.predicateForSamples(withStart: fromDate,
                                                            end: toDate,
                                                            options: [])
                let query = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .stepCount)!,
                                                        quantitySamplePredicate: predicate,
                                                        options: .cumulativeSum,
                                                        anchorDate: fromDate,
                                                        intervalComponents: DateComponents(day: 1))
                query.initialResultsHandler = { _, results, _ in
                    /// `results (HKStatisticsCollection?)` からクエリ結果を取り出す。
                    guard let statsCollection = results else { return }
                    /// クエリ結果から期間（開始日・終了日）を指定して歩数の統計情報を取り出す。
                    statsCollection.enumerateStatistics(from: fromDate, to: toDate) { statistics, _ in
                        /// `statistics` に最小単位（今回は１日分の歩数）のサンプルデータが返ってくる。
                        /// `statistics.sumQuantity()` でサンプルデータの合計（１日の合計歩数）を取得する。
                        if let quantity = statistics.sumQuantity() {
                            /// サンプルデータは`quantity.doubleValue`で取り出し、単位を指定して取得する。
                            /// 単位：歩数の場合`HKUnit.count()`と指定する。（歩行速度の場合：`HKUnit.meter()`、歩行距離の場合：`HKUnit(from: "m/s")`といった単位を指定する。）
                            let stepValue = quantity.doubleValue(for: HKUnit.count())
                            /// 取得した歩数を配列に格納する。
                            self.sampleArray2.append(Int(stepValue))
                            //print("sampleArray", self.sampleArray2)
                        } else {
                            // No Data
                            self.sampleArray2.append(0)
                            //print("sampleArray", self.sampleArray2)
                            //print("あああ")
                        }
                    }
                    DispatchQueue.main.async {
                        self.sampleArray2.remove(at: self.sampleArray2.count - 1)
                        self.sampleArray = self.sampleArray2
                        //print("最終確認", self.sampleArray)
                        self.sumWalking = self.sampleArray.reduce(0, +)
                    }
                }
                HKHealthStore().execute(query)
            }
        }
    }
}
