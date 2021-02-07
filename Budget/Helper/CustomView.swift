//
//  CustomView.swift
//  Budget
//
//  Created by Nicholas HwanG on 11/28/19.
//  Copyright © 2019 Hwang. All rights reserved.
//

import SwiftUI

extension Double {
    var clean: String {
        return String(format: String(self).contains(".0") || String(self).contains(".00") ? "%.0f" : "%.2f", self)
    }
}

class EnvironmentModel: ObservableObject {
    @Published var wrongAttemptText = Int.zero
    @Published var wrongAttemptIcon = Int.zero
    @Published var pieAnimation = false
    @Published var language = ""
}

struct CustomCell: View {
    @Environment(\.managedObjectContext) var context
    @State private var selectedWidth: CGFloat = CGFloat.zero
    @State private var dragAmount = CGSize.zero
    @State private var isOpenDelete = false
    var finance: Finance?
    var image: String
    var note: String?
    var sum: Double?
    var amount: Double
    var type: String
    var color: String?
    var date: Date?
    var imageColor: String
    var capsuleCalculation = UIScreen.main.bounds.width * 62 / 100
    
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    func percentCalculation() -> Int {
        let result = amount / sum! * 100
        guard !(result.isNaN || result.isInfinite) else {
            return 0
        }
        return Int(result)
    }
    
    func calculation() -> CGFloat {
        let result = Double(capsuleCalculation - 2) * amount / sum!
        
        guard !(result.isNaN || result.isInfinite) else {
            return 0
        }
        return CGFloat(result)
    }
    
    private func deleteFinance() {
        context.delete(finance!)
        do {
            try self.context.save()
        } catch {
            // handle the Core Data error
        }
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if sum == nil {
                Image("TrashIcon")
                    .frame(width: dragAmount.width + selectedWidth <= -UIScreen.main.bounds.width / 2 ? -dragAmount.width - selectedWidth : 60, height: 60)
                    .background(Color.red)
                    .animation(.spring())
                    .onTapGesture {
                        self.deleteFinance()
                }
            }
            ZStack {
                Rectangle()
                    .foregroundColor(Color.white)
                HStack {
                    HStack(alignment: .bottom) {
                        ZStack {
                            Rectangle()
                                .frame(width: 46, height: 46)
                                .cornerRadius(12)
                                .foregroundColor(Color(UIColor(named: sum == nil ? imageColor : color!) ?? UIColor.white))
                            Image(image)
                                .resizable()
                            .frame(width: 60, height: 60)
                        }
                        VStack(alignment: .leading) {
                            HStack(alignment: .bottom) {
                                if note != nil {
                                    VStack(alignment: .leading) {
                                        Text(note!.description)
                                        Text(timeFormatter.string(from: date!))
                                            .foregroundColor(Color.gray)
                                            .font(.system(size: 14))
                                    }
                                    .offset(y: 12)
                                }
                                if sum != nil {
                                    HStack(alignment: .bottom) {
                                        VStack(spacing: 2) {
                                            if type == "Income" {
                                                Text("+ \(amount.clean)")
                                                    .fontWeight(.light)
                                                    .foregroundColor(Color(UIColor(named: "Income")!))
                                            }
                                            else {
                                                Text("- \(amount.clean)")
                                                    .fontWeight(.light)
                                                    .foregroundColor(Color(UIColor(named: "Expense")!))
                                                
                                            }
                                            ZStack(alignment: .leading) {
                                                ZStack {
                                                    Capsule()
                                                        .foregroundColor(Color.gray)
                                                        .frame(width: capsuleCalculation, height: 14)
                                                    Capsule()
                                                        .foregroundColor(Color.white)
                                                        .frame(width: capsuleCalculation - 2, height: 12)
                                                }
                                                Capsule()
                                                    .foregroundColor(Color(UIColor(named: color!) ?? UIColor.black))
                                                    .frame(width: calculation(), height: 12)
                                                    .offset(x: 1)
                                            }
                                            .animation(.spring())
                                        }
                                        Text("\(percentCalculation())%")
                                    }
                                    .offset(y: 12)
                                }
                                Spacer()
                                if sum == nil {
                                    if type == "Income" {
                                        Text("+ \(amount.clean)")
                                            .foregroundColor(Color(UIColor(named: "Income")!))
                                            .fontWeight(.light)
                                            .padding(.trailing)
                                    }
                                    else {
                                        Text("- \(amount.clean)")
                                            .fontWeight(.light)
                                            .foregroundColor(Color(UIColor(named: "Expense")!))
                                            .padding(.trailing)
                                    }
                                }
                            }
                            Spacer()
                            Divider()
                        }
                    }
                }
            }
            .offset(x: selectedWidth)
            .onTapGesture {
                withAnimation {
                    if self.sum == nil {
                        if self.isOpenDelete {
                            self.selectedWidth = -60
                            self.isOpenDelete.toggle()
                        } else {
                            self.selectedWidth = CGFloat.zero
                            self.isOpenDelete.toggle()
                        }
                    }
                }
            }
//            .offset(x: dragAmount.width + selectedWidth)
//            .gesture( sum == nil ?
//                DragGesture()
//                    .onChanged({ (value) in
//                        if value.translation.width < 0 || self.selectedWidth == -60 {
//                            if value.translation.width <= 60 {
//                                self.dragAmount = value.translation
//                            }
//                        }
//                    })
//                    .onEnded({ (value) in
//                        withAnimation(.spring()) {
//                            self.dragAmount = .zero
//                            if value.translation.width <= -UIScreen.main.bounds.width / 2 {
//                                self.deleteFinance()
//                            } else {
//                                if self.selectedWidth == -60 {
//                                    if value.translation.width > 30 {
//                                        self.selectedWidth = CGFloat.zero
//                                    } else {
//                                        self.selectedWidth = -60
//                                    }
//                                } else {
//                                    if value.translation.width > -30 {
//                                        self.selectedWidth = CGFloat.zero
//                                    } else {
//                                        self.selectedWidth = -60
//                                    }
//                                }
//                            }
//                        }
//                    })
//                : nil)
        }
        .background(Color.gray)
        .padding(.trailing)
        .frame(width: UIScreen.main.bounds.width)
    }
}


public struct PieChartCell : View {
    @EnvironmentObject var model: EnvironmentModel
    var rect: CGRect
    var radius: CGFloat {
        return min(rect.width, rect.height)/2
    }
    var startDeg: Double
    var endDeg: Double
    var path: Path {
        var path = Path()
        path.addArc(center:rect.mid , radius:self.radius, startAngle: Angle(degrees: self.startDeg), endAngle: Angle(degrees: self.endDeg), clockwise: false)
        path.addLine(to: rect.mid)
        path.closeSubpath()
        return path
    }
    var index: Int
    var backgroundColor: Color
    var accentColor: String
    public var body: some View {
        path
            .fill()
            .foregroundColor(Color(UIColor(named: self.accentColor)!))
            .overlay(path.stroke(self.backgroundColor, lineWidth: 4))
            .scaleEffect(model.pieAnimation ? 1 : 0)
            .animation(Animation.easeInOut(duration: 0.8).delay(Double(index) * 0.1))
    }
}

extension CGRect {
    var mid: CGPoint {
        return CGPoint(x:self.midX, y: self.midY)
    }
}


struct PieSlice: Identifiable, Hashable {
    let id = UUID()
    var startDeg: Double
    var endDeg: Double
    var value: Double
    var normalizedValue: Double
    var color: String
}


public struct PieChartRow : View {
    var data: [IconStruct]
    var backgroundColor: Color
    var slices: [PieSlice] {
        var tempSlices:[PieSlice] = []
        var lastEndDeg:Double = Double.zero
        let maxValue = data.map { $0.amount }.reduce(0, +)
        for slice in data {
            let normalized:Double = Double(slice.amount)/Double(maxValue)
            let startDeg = lastEndDeg
            let endDeg = lastEndDeg + (normalized * 360)
            lastEndDeg = endDeg
            tempSlices.append(PieSlice(startDeg: startDeg, endDeg: endDeg, value: slice.amount, normalizedValue: normalized, color: slice.color))
        }
        return tempSlices
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<self.slices.count, id: \.self){ index in
                    PieChartCell(rect: geometry.frame(in: .local), startDeg: self.slices[index].startDeg, endDeg: self.slices[index].endDeg, index: index, backgroundColor: self.backgroundColor, accentColor: self.slices[index].color)
                }
            }
        }
    }
}

struct CustomDatePicker: UIViewRepresentable {
    @Binding var date: Date
    @EnvironmentObject var model: EnvironmentModel
    private let datePicker = UIDatePicker()

    func makeUIView(context: Context) -> UIDatePicker {
        datePicker.datePickerMode = .date
        let loc = Locale(identifier: model.language == "Russian" ? "ru" : "en")
        datePicker.locale = loc
        datePicker.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
        return datePicker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        datePicker.date = date
    }

    func makeCoordinator() -> CustomDatePicker.Coordinator {
        Coordinator(date: $date)
    }

    class Coordinator: NSObject {
        private let date: Binding<Date>

        init(date: Binding<Date>) {
            self.date = date
        }

        @objc func changed(_ sender: UIDatePicker) {
            self.date.wrappedValue = sender.date
        }
    }
}
