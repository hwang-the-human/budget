//
//  CreateBudgetView.swift
//  Budget
//
//  Created by Nicholas HwanG on 11/8/19.
//  Copyright © 2019 Hwang. All rights reserved.
//

import SwiftUI
import CoreData
import AVFoundation

struct KButton: Identifiable, Hashable {
    let id = UUID()
    var image: String?
    var name: String?
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color(#colorLiteral(red: 0.8756325841, green: 0.8937125802, blue: 0.9130560756, alpha: 1)) : Color.white)
            .cornerRadius(10)
            .offset(y: configuration.isPressed ? -32 : 0)
            .scaleEffect(configuration.isPressed ? 1.5 : 1)
            .animation(.none)
    }
}

var audioPlayer: AVAudioPlayer?
func playSound(sound: String) {
    if let path = Bundle.main.path(forResource: sound, ofType: "mp3") {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
        } catch {
            //"Could not play the sound file."
        }
    }
}

struct CreateBudgetView: View {
    @EnvironmentObject var model: EnvironmentModel
    @Environment(\.managedObjectContext) var context
    @State private var feedback = UINotificationFeedbackGenerator()
    @State private var selectedIcon = ""
    @State private var selectedColor = ""
    @State private var amountText = ""
    @State private var noteText = ""
    @State private var isOpenKeyboard = true
    @State private var frameChanged: CGFloat = 500
    @State private var limitText = 0
    @State private var selectedLetter = " "

    @FetchRequest(
        entity: Icon.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Icon.date, ascending: true)
        ]
    ) var iconArray: FetchedResults<Icon>

    @FetchRequest(
        entity: Finance.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Finance.date, ascending: false)
        ],
        predicate: NSPredicate(format: "date >= %@", Calendar.current.startOfDay(for: Date()) as NSDate)
    ) var financeArray: FetchedResults<Finance>

    private let digitDoubleArray: [[KButton]] = [
        [.init(name: "1"),.init(name: "2"),.init(name: "3"),.init(image: "DeleteIcon")],
        [.init(name: "4"),.init(name: "5"),.init(name: "6"),.init(image: "KeyboardIcon")],
        [.init(name: "7"),.init(name: "8"),.init(name: "9"),.init(image: "IncomeIcon")],
        [.init(name: "0"),.init(name: "00"),.init(name: "."),.init(image: "ExpenseIcon")]
    ]

    private let EnglishLetterDoubleArray: [[KButton]] = [
        [.init(name: "q"),.init(name: "w"),.init(name: "e"),.init(name: "r"),.init(name: "t"),.init(name: "y"),.init(name: "u"),.init(name: "i"),.init(name: "o"),.init(name: "p")],
        [.init(name: "a"),.init(name: "s"),.init(name: "d"),.init(name: "f"),.init(name: "g"),.init(name: "h"),.init(name: "j"),.init(name: "k"),.init(name: "l")],
        [.init(name: ""),.init(name: "z"),.init(name: "x"),.init(name: "c"),.init(name: "v"),.init(name: "b"),.init(name: "n"),.init(name: "m"),.init(image: "DeleteIcon")],
        [.init(image: "KeyboardIcon"),.init(name: ""),.init(image: "SpaceIcon"),.init(name: ""),.init(image: "IncomeIcon"),.init(image: "ExpenseIcon")]
    ]

    private let RussianLetterDoubleArray: [[KButton]] = [
        [.init(name: "й"),.init(name: "ц"),.init(name: "у"),.init(name: "к"),.init(name: "е"),.init(name: "н"),.init(name: "г"),.init(name: "ш"),.init(name: "щ"),.init(name: "з"),.init(name: "х"),.init(name: "ъ")],
        [.init(name: "ф"),.init(name: "ы"),.init(name: "в"),.init(name: "а"),.init(name: "п"),.init(name: "р"),.init(name: "о"),.init(name: "л"),.init(name: "д"),.init(name: "ж"),.init(name: "э")],
        [.init(name: ""),.init(name: "я"),.init(name: "ч"),.init(name: "с"),.init(name: "м"),.init(name: "и"),.init(name: "т"),.init(name: "ь"),.init(name: "б"),.init(name: "ю"),.init(image: "DeleteIcon")],
        [.init(image: "KeyboardIcon"),.init(name: ""),.init(image: "SpaceIcon"),.init(name: ""),.init(image: "IncomeIcon"),.init(image: "ExpenseIcon")]
    ]

    private func addFinance(type: String) {
        if amountText != "" && selectedIcon != "" {
            let finance = NSEntityDescription.insertNewObject(forEntityName: "Finance", into: context)
            self.feedback.notificationOccurred(.success)
            playSound(sound: "Done")
            finance.setValue(Double(amountText), forKey: "amount")
            finance.setValue(noteText.capitalized, forKey: "note")
            finance.setValue(Date(), forKey: "date")
            finance.setValue(selectedIcon, forKey: "icon")
            finance.setValue(selectedColor, forKey: "color")
            finance.setValue(type, forKey: "type")
            do {
                try context.save()
                amountText = ""
                noteText = ""
            } catch {
                // handle the Core Data error
            }
        } else {
            playSound(sound: "Error")
            if amountText == "" {
                model.wrongAttemptText += 1
            }
            if selectedIcon == "" {
                model.wrongAttemptIcon += 1
            }
        }
    }

    private func changeKeyboard(height: CGFloat, open: Bool) {
        frameChanged = CGFloat(height)
        isOpenKeyboard = open
    }

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: model.language == "Russian" ? "Ru" : "Us")
        return formatter
    }

    var body: some View {
        NavigationView {
            List {
                ScrollView {
                    VStack(spacing: 16) {
                        filterListCreate(amountText: amountText, noteText: noteText.capitalized)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(iconArray, id: \.self) { icon in
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(Color(UIColor(named: icon.color!)!))
                                            .frame(width: 40, height: 40)
                                            .cornerRadius(10)
                                        Image(icon.image!)
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                    }
                                    .frame(width: 40 * 1.43, height: 40 * 1.43)
                                    .scaleEffect(self.selectedIcon == icon.image && self.selectedColor == icon.color ? 1.43 : 1)
                                    .onTapGesture {
                                        self.selectedIcon = icon.image!
                                        self.selectedColor = icon.color!
                                    }
                                    .onLongPressGesture(minimumDuration: 2) {
                                        self.context.delete(icon)
                                        self.selectedIcon = ""
                                        do {
                                            try self.context.save()
                                        } catch {
                                            // handle the Core Data error
                                        }
                                    }
                                }

                                NavigationLink(destination: CreateIconView()) {
                                    Text("+")
                                        .frame(width: 40, height: 40)
                                        .font(.system(size: 30))
                                }
                            }
                            .modifier(Shake(animatableData: CGFloat(self.model.wrongAttemptIcon)))
                        }

                        if isOpenKeyboard == true {
                            ForEach (digitDoubleArray, id: \.self) { digitArray in
                                HStack {
                                    ForEach (digitArray) { digit in
                                        Button(action: {
                                            playSound(sound: "Click")
                                            if digit.name != nil {
                                                if self.amountText.count < 9 {
                                                    if self.amountText.count < 1 {
                                                        if digit.name != "0" && digit.name != "00" && digit.name != "." {
                                                            self.amountText += digit.name!
                                                        }
                                                    } else {
                                                        if self.amountText.contains(".") {
                                                            if self.amountText.count < self.limitText + 2 {
                                                                if digit.name! != "." {
                                                                    self.amountText += digit.name!
                                                                }
                                                            }
                                                        } else {
                                                            self.amountText += digit.name!
                                                            self.limitText = self.amountText.count
                                                        }
                                                    }
                                                }
                                            } else {
                                                switch digit.image! {
                                                case "DeleteIcon":
                                                    self.amountText = String(self.amountText.dropLast())
                                                case "KeyboardIcon":
                                                    self.changeKeyboard(height: 400, open: false)
                                                case "IncomeIcon":
                                                    self.addFinance(type: "Income")
                                                default:
                                                    self.addFinance(type: "Expense")
                                                }
                                            }
                                        }) {
                                            if digit.name != nil {
                                                Text(digit.name!)
                                                    .font(.system(size: CGFloat(30)))
                                                    .fontWeight(.light)
                                                    .foregroundColor(Color.black)
                                                    .frame(width: 78)
                                            } else {
                                                Image(digit.image!)
                                                    .padding(.leading, 10)
                                            }
                                        }
                                    }
                                }
                            }

                        } else {
                            VStack(spacing: 10) {
                                ForEach (model.language == "Russian" ? RussianLetterDoubleArray : EnglishLetterDoubleArray, id: \.self) { letterArray in
                                    HStack {
                                        ForEach (letterArray) { letter in
                                            Button(action: {
                                                if letter.name != "" {
                                                    playSound(sound: "Click")
                                                }

                                                if letter.name != nil {
                                                    if self.noteText.count < 20 {
                                                        self.selectedLetter = letter.name!
                                                        self.noteText += letter.name!
                                                    }
                                                }
                                            }) {
                                                if letter.name != nil {
                                                        Text(letter.name!)
                                                            .font(.system(size: CGFloat(30)))
                                                            .fontWeight(.light)
                                                            .foregroundColor(Color.black)
                                                            .frame(width: self.model.language == "Russian" ? 30 : 38)
                                                    

                                                }
                                            }
                                            .buttonStyle(ScaleButtonStyle())
                                            
                                            Button(action: {
                                                if letter.name != "" {
                                                    playSound(sound: "Click")
                                                }

                                                if letter.name == nil {
                                                    switch letter.image! {
                                                    case "SpaceIcon":
                                                        self.noteText += " "
                                                    case "DeleteIcon":
                                                        self.noteText = String(self.noteText.dropLast())
                                                    case "KeyboardIcon":
                                                        self.changeKeyboard(height: 500, open: true)
                                                    case "IncomeIcon":
                                                        if self.amountText != "" && self.selectedIcon != "" {
                                                            self.changeKeyboard(height: 500, open: true)
                                                        }
                                                        self.addFinance(type: "Income")
                                                    default:
                                                        if self.amountText != "" && self.selectedIcon != "" {
                                                            self.changeKeyboard(height: 500, open: true)
                                                        }
                                                        self.addFinance(type: "Expense")
                                                    }
                                                }
                                            }) {

                                                if letter.name == nil {
                                                Image(letter.image!)
                                                    .frame(height: 35)

                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top)
                .animation(.spring())
                .listRowInsets(EdgeInsets())
                .frame(height: frameChanged)


                Section(header: Text(model.language == "Russian" ? "Сегодня - \(dateFormatter.string(from: Date()).capitalized)" : "Today - \(dateFormatter.string(from: Date()))")) {
                    ForEach(financeArray, id: \.self) { (finance: Finance) in
                        CustomCell(finance: finance,image: finance.icon, note: finance.note!, amount: finance.amount, type: finance.type, date: finance.date, imageColor: finance.color)
                    }
                    HStack {
                        Spacer()
                        Text(model.language == "Russian" ? "Нажмите на ячейку, чтобы удалить её." : "Tap on the cell to delete it.")
                            .foregroundColor(Color.gray)
                            .font(.system(size: 14))
                        Spacer()
                    }
                }
            }
            .navigationBarTitle(model.language == "Russian" ? "Назад" : "Back")
            .navigationBarHidden(true)
        }
    }
}

struct filterListCreate: View {
    @EnvironmentObject var model: EnvironmentModel
    var fetchRequest: FetchRequest<Finance>
    var financeArray: FetchedResults<Finance> {
        fetchRequest.wrappedValue
    }

    @State private var language = ""
    var amountText: String
    var noteText: String

    var financeText: [String] {
        return financeArray.map { $0.note! }
    }

    var body: some View {
        VStack(spacing: 6) {
            if amountText.isEmpty {
                Text(language == "Russian" ? "Введите Сумму" : "Enter Amount")
                    .foregroundColor(Color.gray)
                    .animation(.none)
                    .modifier(Shake(animatableData: CGFloat(model.wrongAttemptText)))
                
            }
            else {
                Text(amountText)
                    .fontWeight(.light)
                    .frame(width: UIScreen.main.bounds.width)
                    .animation(.none)
            }
            
            if noteText.isEmpty {
                Text(language == "Russian" ? "Введите Заметку" : "Enter Note")
                    .foregroundColor(Color.gray)
                    .animation(.none)
            }
            else {
                ZStack(alignment: .leading) {
                    Text(financeText.isEmpty ? "" : financeText[0])
                        .foregroundColor(Color.gray)
                        .fontWeight(.light)
                    Text(noteText)
                        .fontWeight(.light)

                }
                .frame(width: UIScreen.main.bounds.width)
                .animation(.none)

            }
        }
        .font(.title)
        .frame(height: 100)
        .onAppear() {
            self.language = UserDefaults.standard.string(forKey: "Language") ?? "English"
        }
    }

    init(amountText: String, noteText: String) {
        self.amountText = amountText
        self.noteText = noteText
        fetchRequest = FetchRequest<Finance>(
            entity: Finance.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Finance.date, ascending: false)
            ], predicate: NSPredicate(format: "note BEGINSWITH %@", noteText)
        )
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                                              y: 0))
    }
}
