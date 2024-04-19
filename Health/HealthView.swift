//
//  HealthView.swift
//  WalkingEventAppDemo
//
//  Created by 小田敏人 on 2022/07/06.
//

import SwiftUI
import HealthKit

struct HealthView: View {
    
    @State private var showActivityView: Bool = false
    
    @Binding var showHealthView: Bool
    @State var sampleArray: [Double] = []
    @ObservedObject var healthManager = HealthManager()
    @State var date = Date()
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter
    }()
    
    init(showHealthView: Binding<Bool>) {
        self._showHealthView = showHealthView
        let calendar = Calendar(identifier: .gregorian)
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let firstDay = calendar.date(from: DateComponents(year: year, month: month))!
        let add = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: add, to: firstDay)!
        healthManager.get(fromDate: firstDay, toDate: lastDay)
    }
    
    var body: some View {
        let url = fileSave(fileName: dateFormatter.string(from: date) + ".pdf")
        NavigationView {
            ZStack {
                
                Color(red: 144/255, green: 215/255, blue: 236/255)
                    .ignoresSafeArea()
                
                VStack {
                    List {
                        HStack {
                            Text("合計")
                            Spacer()
                            Text(String(healthManager.sumWalking) + "歩")
                        }
                        
                        ForEach(healthManager.sampleArray.indices, id:\.self) {index in
                            HStack {
                                Text(String(index + 1) + "日")
                                Spacer()
                                Text(String(healthManager.sampleArray[index]) + "歩")
                            }
                        }
                        
                    }
                }
            }
            .navigationTitle(dateFormatter.string(from: date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(">>") {
                        self.date = Calendar.current.date(byAdding: .month, value: 1, to: self.date)!
                        let calendar = Calendar(identifier: .gregorian)
                        let year = Calendar.current.component(.year, from: date)
                        let month = Calendar.current.component(.month, from: date)
                        let firstDay = calendar.date(from: DateComponents(year: year, month: month))!
                        let add = DateComponents(month: 1)
                        let lastDay = calendar.date(byAdding: add, to: firstDay)!
                        healthManager.get(fromDate: firstDay, toDate: lastDay)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("終了") {
                        self.showHealthView = false
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("<<") {
                        self.date = Calendar.current.date(byAdding: .month, value: -1, to: self.date)!
                        let calendar = Calendar(identifier: .gregorian)
                        let year = Calendar.current.component(.year, from: date)
                        let month = Calendar.current.component(.month, from: date)
                        let firstDay = calendar.date(from: DateComponents(year: year, month: month))!
                        let add = DateComponents(month: 1)
                        let lastDay = calendar.date(byAdding: add, to: firstDay)!
                        healthManager.get(fromDate: firstDay, toDate: lastDay)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        createPDF()
                        self.showActivityView.toggle()
                    }
                }
            }
            .sheet(isPresented: self.$showActivityView) {
                ActivityView(
                    activityItems: [url],

                    applicationActivities: nil
                )
            }
        }
        .navigationViewStyle(.stack)
    }
    
    func createPDF() {
        var htmlString = ""
        let htmlHeader = headerHTMLstring(walkMonth: dateFormatter.string(from: date))
        htmlString.append(htmlHeader)
        var totalPrice = 0
        for i in 0 ..< healthManager.sampleArray.count {
            let name = "\(i + 1)日"
            let price = healthManager.sampleArray[i]
            let rowString = getSingleRow(itemName: name, itemPrice: price)
            htmlString.append(rowString)
            totalPrice += price
        }
        htmlString.append("\n 合計歩数: \(totalPrice) 歩 \n")
        let footerString = footerHTMLstring()
        htmlString.append(footerString)
        
        let renderer = UIPrintPageRenderer()
        let paperSize = CGSize(width: 595.2, height: 841.8)
        let paperFrame = CGRect(origin: .zero, size: paperSize)
        renderer.setValue(paperFrame, forKey: "paperRect")
        renderer.setValue(paperFrame, forKey: "printableRect")
        
        let formatter = UIMarkupTextPrintFormatter(markupText: htmlString)
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, [:])
        for pageI in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: pageI, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + dateFormatter.string(from: date) + ".pdf"
            pdfData.write(toFile: documentsFileName, atomically: true)
        }
    }

    func headerHTMLstring(walkMonth: String) -> String {
        //htmlヘッダーを生成します。
        return """
        <!DOCTYPE html>
        <html>
            <head>
                    <title>\(walkMonth)歩数情報</title>
            <style>
                    table, th, td {
                      border: 1px solid black;
                      border-collapse: collapse;
                    }
            </style>
            <body>
                <h2>\(walkMonth)歩数情報</h2>
                <table style="width:100%">
                    <tr>
                        <th>日付</th>
                        <th>歩数</th>
                    </tr>
        """
    }

    func getSingleRow(itemName: String, itemPrice: Int) -> String {
        return """
        <tr>
            <td>\(itemName)</td>
            <td>\(String(itemPrice))歩</td>
        </tr>
        """
    }

    func footerHTMLstring() -> String {
        return """
            </table>

            </body>
        </html>
        """
    }

    func fileSave(fileName: String) -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = dir.appendingPathComponent(fileName, isDirectory: false)
        return filePath
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ActivityView>
    ) -> UIActivityViewController {
        return UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityView>
    ) {
        // Nothing to do
    }
}

 struct HealthView_Previews: PreviewProvider {
     static var previews: some View {
         HealthView(showHealthView: Binding.constant(true))
     }
 }
 
