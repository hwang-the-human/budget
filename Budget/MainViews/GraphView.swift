//
//  GraphView.swift
//  Budget
//
//  Created by Nicholas HwanG on 11/8/19.
//  Copyright © 2019 Hwang. All rights reserved.
//

import SwiftUI
struct IconStruct: Equatable, Hashable {
    var amount: Double
    var icon: String
    var color: String
}

struct GraphView: View {
    @EnvironmentObject var model: EnvironmentModel
    @State private var fromDate = Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: Date())!
    @State private var toDate = Date()
    @State private var selectedType = "type != %@"
    @State private var selectedDate = true
    @State private var searchText = ""
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: model.language == "Russian" ? "Ru" : "Us")
        return formatter
    }
    
    var body: some View {
        List {
            VStack {
                HStack {
                    Picker("", selection: $selectedType) {
                        Text(model.language == "Russian" ? "Расходы" : "Expenses").tag("type != %@")
                        Text(model.language == "Russian" ? "Доходы" : "Incomes").tag("type == %@")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                }
                HStack {
                    Picker("", selection: $selectedDate) {
                        if model.language == "Russian" {
                            Text("С: \(dateFormatter.string(from: fromDate).capitalized)").tag(true)
                            Text("По: \(dateFormatter.string(from: toDate).capitalized)").tag(false)
                        } else {
                            Text("From: \(dateFormatter.string(from: fromDate).capitalized)").tag(true)
                            Text("To: \(dateFormatter.string(from: toDate).capitalized)").tag(false)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .animation(.none)
                    
                }
                
                if selectedDate {
                    CustomDatePicker(date: $fromDate)
                } else {
                    CustomDatePicker(date: $toDate)
                }
            }
            
            filterTotalText(selectedType: selectedType, from: fromDate, to: toDate, searchList: false, text: "")
            filterTotalList(selectedType: selectedType, from: fromDate, to: toDate)
        }
        .frame(width: UIScreen.main.bounds.width)
        .animation(.default)
    }
}

struct filterTotalText: View {
    @EnvironmentObject var model: EnvironmentModel
    var fetchRequest: FetchRequest<Finance>
    var financeArray: FetchedResults<Finance> {
        fetchRequest.wrappedValue
    }
    
    var iconArray: [IconStruct] {
        var array:[IconStruct] = []
        for finance in financeArray {
            var finalAmount: Double = Double.zero
            let icon = finance.icon
            let color = finance.color
            for inFinance in financeArray {
                if inFinance.icon == icon && inFinance.color == color {
                    finalAmount += inFinance.amount
                }
            }
            array.append(IconStruct(amount: finalAmount, icon: finance.icon, color: finance.color))
        }
        return unique(array: array)
    }
    
    func unique(array: [IconStruct]) -> [IconStruct] {
        
        var uniqueArray = [IconStruct]()
        
        for element in array {
            if !uniqueArray.contains(element) {
                uniqueArray.append(element)
            }
        }
        return uniqueArray
    }
    
    var selectedType: String
    var fromDate: Date
    var toDate: Date
    var searchList: Bool
    
    var totalAmount: Double {
        return financeArray.map { $0.amount }.reduce(0,+)
    }
    
    var body: some View {
        VStack {
            Color(UIColor.white)
            HStack {
                Text(model.language == "Russian" ? "Общая Сумма: " : "Total amount: ")
                    .foregroundColor(Color.gray)
                    .font(Font.system(size: 24))
                if selectedType == "type != %@" {
                    Text("- \(totalAmount.clean)")
                        .fontWeight(.light)
                        .foregroundColor(Color(UIColor(named: "Expense")!))
                } else {
                    Text("+ \(totalAmount.clean)")
                        .fontWeight(.light)
                        .foregroundColor(Color(UIColor(named: "Income")!))
                }
            }
            .font(.title)
            
            if !searchList {
                PieChartRow(data: iconArray, backgroundColor: Color(UIColor.white))
                    .frame(width: 300, height: 300)
            }
        }
        
    }
    
    
    init(selectedType: String, from: Date, to: Date, searchList: Bool, text: String?) {
        self.searchList = searchList
        self.selectedType = selectedType
        self.fromDate = from
        self.toDate = to
        if !text!.isEmpty {
            fetchRequest = FetchRequest<Finance>(
                entity: Finance.entity(),
                sortDescriptors: [
                    NSSortDescriptor(keyPath: \Finance.date, ascending: true)
                ], predicate:
                NSCompoundPredicate(notPredicateWithSubpredicate: NSCompoundPredicate.init(type: .or, subpredicates: [
                    NSPredicate(format: selectedType, "Expense"),
                    NSPredicate(format: "NOT note BEGINSWITH %@", text!),
                    NSPredicate(format: "date < %@ OR date >= %@", (Calendar.current.startOfDay(for: from) as NSDate), Calendar.current.date(byAdding: .day, value: 0, to: to)! as NSDate )
                ]))
            )
        } else {
            fetchRequest = FetchRequest<Finance>(
                entity: Finance.entity(),
                sortDescriptors: [
                    NSSortDescriptor(keyPath: \Finance.date, ascending: true)
                ], predicate:
                NSCompoundPredicate(notPredicateWithSubpredicate: NSCompoundPredicate.init(type: .or, subpredicates: [
                    NSPredicate(format: selectedType, "Expense"),
                    NSPredicate(format: "date < %@ OR date >= %@", (Calendar.current.startOfDay(for: from) as NSDate), Calendar.current.date(byAdding: .day, value: 0, to: to)! as NSDate )
                ]))
            )
        }
    }
}

struct filterTotalList: View {
    var fetchRequest: FetchRequest<Finance>
    var financeArray: FetchedResults<Finance> {
        fetchRequest.wrappedValue
    }
    
    var iconArray: [IconStruct] {
        var array:[IconStruct] = []
        for finance in financeArray {
            var finalAmount: Double = Double.zero
            let icon = finance.icon
            let color = finance.color
            for inFinance in financeArray {
                if inFinance.icon == icon && inFinance.color == color {
                    finalAmount += inFinance.amount
                }
            }
            array.append(IconStruct(amount: finalAmount, icon: finance.icon, color: finance.color))
        }
        return unique(array: array)
    }
    
    func unique(array: [IconStruct]) -> [IconStruct] {
        
        var uniqueArray = [IconStruct]()
        
        for element in array {
            if !uniqueArray.contains(element) {
                uniqueArray.append(element)
            }
        }
        return uniqueArray
    }
    
    var selectedType: String
    var fromDate: Date
    var toDate: Date
    
    var totalAmount: Double {
        return financeArray.map { $0.amount }.reduce(0,+)
    }
    
    var body: some View {
        ForEach(iconArray.sorted { $0.amount > $1.amount }, id: \.self) { icon in
            filterListCell(type: self.selectedType, image: icon.icon, color: icon.color, from: self.fromDate, to: self.toDate, sum: self.totalAmount)
        }
    }
    
    init(selectedType: String, from: Date, to: Date) {
        self.selectedType = selectedType
        self.fromDate = from
        self.toDate = to
        fetchRequest = FetchRequest<Finance>(
            entity: Finance.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Finance.date, ascending: true)
            ], predicate:
            NSCompoundPredicate(notPredicateWithSubpredicate: NSCompoundPredicate.init(type: .or, subpredicates: [
                NSPredicate(format: selectedType, "Expense"),
                NSPredicate(format: "date < %@ OR date >= %@", (Calendar.current.startOfDay(for: from) as NSDate), Calendar.current.date(byAdding: .day, value: 0, to: to)! as NSDate )
            ]))
        )
    }
}

struct filterListCell: View {
    var fetchRequest: FetchRequest<Finance>
    var financeArray: FetchedResults<Finance> {
        fetchRequest.wrappedValue
    }
    
    var type: String
    var image: String
    var color: String
    var sum: Double
    
    var totalAmount: Double {
        return financeArray.map { $0.amount }.reduce(0,+)
    }
    
    var body: some View {
        VStack {
            if !totalAmount.isZero {
                CustomCell(image: image, sum: sum, amount: totalAmount, type: type, color: color, imageColor: color)
            }
        }
    }
    
    init(type: String, image: String, color: String, from: Date, to: Date, sum: Double) {
        self.image = image
        self.color = color
        self.sum = sum
        if type == "type == %@" {
            self.type = "Income"
        } else {
            self.type = "Expense"
        }
        fetchRequest = FetchRequest<Finance>(
            entity: Finance.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Finance.date, ascending: true)
            ], predicate:
            NSCompoundPredicate(notPredicateWithSubpredicate: NSCompoundPredicate.init(type: .or, subpredicates: [
                NSPredicate(format: type, "Expense"),
                NSPredicate(format: "icon != %@", image),
                NSPredicate(format: "color != %@", color),
                NSPredicate(format: "date < %@ OR date >= %@", (Calendar.current.startOfDay(for: from) as NSDate), Calendar.current.date(byAdding: .day, value: 0, to: to)! as NSDate )
            ]))
        )
    }
}
