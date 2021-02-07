//
//  ContentView.swift
//  Budget
//
//  Created by Nicholas HwanG on 10/23/19.
//  Copyright © 2019 Hwang. All rights reserved.
//

import SwiftUI
struct MainView: View {
    @EnvironmentObject var model: EnvironmentModel
    @Environment(\.managedObjectContext) var context
    @State private var showCreateBudgetView = false
    @State private var showSettingsView = false
    @State private var refreshView = true
    @State private var selectedWidth: CGFloat = CGFloat.zero
    @State private var dragAmount = CGSize.zero
    @State private var indexOfView = 1
    private var screenWidth = UIScreen.main.bounds.width
    
    
    @FetchRequest(
        entity: Finance.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Finance.date, ascending: true)
        ],
        predicate: NSPredicate(format: "type == %@", "Expense")
    ) var expenseArray: FetchedResults<Finance>
    
    @FetchRequest(
        entity: Finance.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Finance.date, ascending: true)
        ],
        predicate: NSPredicate(format: "type != %@", "Expense")
    ) var incomeArray: FetchedResults<Finance>
    
    
    var expenseAmount: Double {
        return expenseArray.map { $0.amount }.reduce(0,+)
    }
    
    var incomeAmount: Double {
        return incomeArray.map { $0.amount }.reduce(0,+)
    }
    
    var totalAmount: Double {
        return incomeAmount - expenseAmount
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
            HStack(spacing: 0) {
                if refreshView {
                    GraphView()
                } else {
                    Text("")
                        .frame(width: screenWidth)
                }
                VStack {
                    HStack(alignment: .top) {
                        VStack {
                            Button(action: {
                                withAnimation(.spring()) {
                                    self.dragAmount = CGSize(width: self.screenWidth, height: CGFloat.zero)
                                    self.selectedWidth = CGFloat.zero
                                    self.indexOfView = Int.zero
                                    self.model.pieAnimation.toggle()
                                }
                            }){
                                Image("PieGraphIcon")
                            }
                            
                            Button(action: {
                                self.showSettingsView.toggle()
                            }){
                                Image("SettingsIcon")
                            }
                            .sheet(isPresented: self.$showSettingsView) {
                                SettingsView().environmentObject(self.model)
                            }
                        }
                        Spacer()
                            .frame(width: UIScreen.main.bounds.width - 126)
                        Button(action: {
                            withAnimation(.spring()) {
                                self.dragAmount = CGSize(width: -self.screenWidth, height: CGFloat.zero)
                                self.selectedWidth = CGFloat.zero
                                self.indexOfView = 2
                            }
                        }){
                            Image("SearchIcon")
                        }
                    }
                    
                    Spacer()
                    
                    Text("\(totalAmount.clean)")
                        .font(.system(size: 50))
                        .fontWeight(.light)
                    
                    Button(action: {
                        self.showCreateBudgetView.toggle()
                    }){
                        Image("AddIcon")
                    }
                    .sheet(isPresented: self.$showCreateBudgetView) {
                        CreateBudgetView().environment(\.managedObjectContext, self.context).environmentObject(self.model)
                            .onAppear() {
                                self.refreshView.toggle()
                        }
                        .onDisappear() {
                            self.refreshView.toggle()
                        }
                    }
                    Spacer()
                }
                .frame(width: screenWidth)
                
                if refreshView {
                    SearchView()
                } else {
                    Text("")
                        .frame(width: screenWidth)
                }
            }
        }
        .onAppear {
            self.model.language = UserDefaults.standard.string(forKey: "Language") ?? ""
        }
        .offset(x: dragAmount.width + selectedWidth)
        .gesture(
            DragGesture()
                .onChanged({ (value) in
                    keyWindow?.endEditing(true)
                    switch self.indexOfView {
                    case 0:
                        self.selectedWidth = self.screenWidth
                        if value.translation.width < 0 {
                            self.dragAmount = value.translation
                        } else {
                            self.dragAmount = .zero
                        }
                    case 1:
                        self.selectedWidth = .zero
                        self.dragAmount = value.translation
                    default:
                        self.selectedWidth = -self.screenWidth
                        if value.translation.width > 0 {
                            self.dragAmount = value.translation
                        } else {
                            self.dragAmount = .zero
                        }
                    }
                })
                .onEnded({ (value) in
                    switch self.indexOfView {
                    case 0:
                        withAnimation(.spring()) {
                            if self.dragAmount.width < -self.screenWidth / 4 {
                                self.dragAmount = CGSize(width: -self.screenWidth, height: CGFloat.zero)
                                self.indexOfView = 1
                                self.model.pieAnimation.toggle()
                            } else {
                                self.dragAmount = .zero
                                self.indexOfView = Int.zero
                            }
                        }
                    case 1:
                        withAnimation(.spring()) {
                            if self.dragAmount.width > self.screenWidth / 4 {
                                self.dragAmount = CGSize(width: self.screenWidth, height: CGFloat.zero)
                                self.indexOfView = Int.zero
                                self.model.pieAnimation.toggle()
                            } else if self.dragAmount.width < -self.screenWidth / 4  {
                                self.dragAmount = CGSize(width: -self.screenWidth, height: CGFloat.zero)
                                self.indexOfView = 2
                            } else {
                                self.dragAmount = .zero
                                self.indexOfView = 1
                            }
                        }
                    default:
                        withAnimation(.spring()) {
                            if self.dragAmount.width > self.screenWidth / 4 {
                                self.dragAmount = CGSize(width: self.screenWidth, height: CGFloat.zero)
                                self.indexOfView = 1
                            } else {
                                self.dragAmount = .zero
                                self.indexOfView = 2
                            }
                        }
                    }
                })
        )
    }
    
    init() {
        UITableView.appearance().separatorStyle = .none
    }
}

let keyWindow = UIApplication.shared.connectedScenes
.filter({$0.activationState == .foregroundActive})
.map({$0 as? UIWindowScene})
.compactMap({$0})
.first?.windows
.filter({$0.isKeyWindow}).first
