//
//  SelectCourseModel.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/20.
//

import Foundation
import Firebase

class SelectCourseModel: ObservableObject {
    
    @Published var list = [SelectCourseName]()
    
    init() {
        getData()
    }
    
    func getData() {
        
        let db = Firestore.firestore()
        
        db.collection("courses").getDocuments { snapshot, error in
            
            if error == nil {
                //No errors
                
                if let snapshot = snapshot {
                    
                    DispatchQueue.main.async {
                        self.list = snapshot.documents.map { d in
                            
                            return SelectCourseName(id: d.documentID,
                                        name: d["name"] as? String ?? "")
                        }
                    }
                }
            }
            else {
                //Handle the error
            }
        }
    }
}
