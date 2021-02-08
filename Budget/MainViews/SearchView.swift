//
//  SearchView.swift
//  Budget
//
//  Created by Nicholas HwanG on 11/8/19.
//  Copyright © 2019 Hwang. All rights reserved.
//

import SwiftUI
import CoreData

struct SearchView: View {
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: model.language == "Russian" ? "Ru" : "Us")
        return formatter
    }
    
    @EnvironmentObject var model: EnvironmentModel
    @State private var fromDate = Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: Date())!
    @State private var toDate = Date()
    @State private var selectedType = "icon == %@"
    @State private var selectedDate = true
    @State private var searchText = ""
    
    var body: some View {
        List {
            VStack {
                TextField(model.language == "Russian" ? "Поиск" : "Search", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Picker("", selection: $selectedType) {
                        Text(model.language == "Russian" ? "Всë" : "Both").tag("icon == %@")
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
                }
                .animation(.none)
                
                if selectedDate {
                    CustomDatePicker(date: $fromDate)
                } else {
                    CustomDatePicker(date: $toDate)
                }
                
            }
            
            if selectedType != "icon == %@" {
                filterTotalText(selectedType: selectedType, from: fromDate, to: toDate, searchList: true, text: searchText)
            }
            
            filterList(type: selectedType, text: searchText, from: fromDate, to: toDate)
            HStack {
                Spacer()
                Text(model.language == "Russian" ? "Нажмите на ячейку, чтобы удалить её." : "Tap on the cell to delete it.")
                    .foregroundColor(Color.gray)
                    .font(.system(size: 14))
                Spacer()
            }
        }
        .frame(width: UIScreen.main.bounds.width)
    }
    
}

struct filterList: View {
    @EnvironmentObject var model: EnvironmentModel
    var fetchRequest: FetchRequest<Finance>
    var financeArray: FetchedResults<Finance> {
        fetchRequest.wrappedValue
    }
    
    var type: String
    var text: String?
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: model.language == "Russian" ? "Ru" : "Us")
        return formatter
    }
    
    var dateFormatter2: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: model.language == "Russian" ? "Ru" : "Us")
        return formatter
    }
    
    var dateArray: [String] {
        return financeArray.map { dateFormatter.string(from: $0.date ?? Date()) }.removingDuplicates()
    }
    
    var body: some View {
        Section {
            ForEach(dateArray, id: \.self) { date in
                Section(header:
                    Text("\(self.dateFormatter2.string(from: self.dateFormatter.date(from: date) ?? Date()).capitalized), \(date.capitalized)")
                        .bold()
                        .padding(4)
                        .offset(x: 12)
                        .listRowInsets(EdgeInsets())
                        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                        .background(Color(#colorLiteral(red: 0.8979505897, green: 0.8981012702, blue: 0.8979307413, alpha: 1)))
                    
                    
                ) {
                    filterColumnList(date: self.dateFormatter.date(from: date)!, type: self.type, text: self.text) { (finance: Finance) in
                        CustomCell(finance: finance, image: finance.icon, note: finance.note, amount: finance.amount, type: finance.type, date: finance.date, imageColor: finance.color)
                    }
                }
            }
        }
    }
    
    init(type: String, text: String?, from: Date, to: Date) {
        self.type = type
        self.text = text
        if !text!.isEmpty {
            fetchRequest = FetchRequest<Finance>(
                entity: Finance.entity(),
                sortDescriptors: [
                    NSSortDescriptor(keyPath: \Finance.date, ascending: false)
                ], predicate:
                NSCompoundPredicate(notPredicateWithSubpredicate: NSCompoundPredicate.init(type: .or, subpredicates: [
                    NSPredicate(format: "NOT note BEGINSWITH %@", text!),
                    NSPredicate(format: type, "Expense"),
                    NSPredicate(format: "date < %@ OR date >= %@", (Calendar.current.startOfDay(for: from) as NSDate), Calendar.current.date(byAdding: .day, value: 0, to: to)! as NSDate )
                ]))
            )
        } else {
            fetchRequest = FetchRequest<Finance>(
                entity: Finance.entity(),
                sortDescriptors: [
                    NSSortDescriptor(keyPath: \Finance.date, ascending: false)
                ], predicate:
                NSCompoundPredicate(notPredicateWithSubpredicate: NSCompoundPredicate.init(type: .or, subpredicates: [
                    NSPredicate(format: type, "Expense"),
                    NSPredicate(format: "date < %@ OR date >= %@", (Calendar.current.startOfDay(for: from) as NSDate), Calendar.current.date(byAdding: .day, value: 0, to: to)! as NSDate )
                ])))
        }
    }
}


struct filterColumnList<T:NSManagedObject, Content:View>: View {
    var fetchRequest: FetchRequest<T>
    var financeArray: FetchedResults<T> {
        fetchRequest.wrappedValue
    }
    
    let content: (T) -> Content
    
    var body: some View {
        ForEach(self.financeArray, id: \.self) { finance in
            self.content(finance)
        }
    }
    
    init(date: Date, type: String, text: String?, @ViewBuilder content: @escaping (T) -> Content) {
        self.content = content
        if !text!.isEmpty {
            fetchRequest = FetchRequest<T>(
                entity: Finance.entity(),
                sortDescriptors: [
                    NSSortDescriptor(keyPath: \Finance.date, ascending: false)
                ],
                predicate: NSCompoundPredicate(notPredicateWithSubpredicate: NSCompoundPredicate.init(type: .or, subpredicates: [
                    NSPredicate(format: type, "Expense"),
                    NSPredicate(format: "NOT note BEGINSWITH %@", text!),
                    NSPredicate(format: "date < %@ OR date >= %@", (Calendar.current.startOfDay(for: date) as NSDate), Calendar.current.date(byAdding: .day, value: 1, to: date)! as NSDate )
                ])))
        } else {
            fetchRequest = FetchRequest<T>(
                entity: Finance.entity(),
                sortDescriptors: [
                    NSSortDescriptor(keyPath: \Finance.date, ascending: false)
                ], predicate:
                NSCompoundPredicate(notPredicateWithSubpredicate: NSCompoundPredicate.init(type: .or, subpredicates: [
                    NSPredicate(format: type, "Expense"),
                    NSPredicate(format: "date < %@ OR date >= %@", (Calendar.current.startOfDay(for: date) as NSDate), Calendar.current.date(byAdding: .day, value: 1, to: date)! as NSDate )
                ])))
        }
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
