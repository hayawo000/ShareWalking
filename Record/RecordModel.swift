//
//  RecordModel.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/23.
//

import Foundation
import Firebase

class RecordModel: ObservableObject {
    
    @Published var list = [Record]()
    let username = UserDefaults.standard.string(forKey: "username") ?? ""
    
    init() {
        getData()
    }
    
    func getData() {
        
        let db = Firestore.firestore()
        db.collection("records").whereField("user", isEqualTo: username).getDocuments { snapshot, error in
            if error == nil {
            
                if let snapshot = snapshot {
                    
                    DispatchQueue.main.async {
                        self.list = snapshot.documents.map { d in
                            
                            return Record(id: d.documentID,
                                          date: d["date"] as? String ?? "",
                                          courseName: d["course"] as? String ?? "",
                                          stepCount: d["steps"] as? Int ?? 0,
                                          meter: d["distance"] as? Double ?? 0.0,
                                          walkTime: d["time"] as? String ?? "")
                        }
                    }
                }
            }
            else {
                
            }
        }
    }
}
