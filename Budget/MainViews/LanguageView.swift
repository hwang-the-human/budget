//
//  LanguageView.swift
//  Budget
//
//  Created by Nicholas HwanG on 1/12/20.
//  Copyright © 2020 Hwang. All rights reserved.
//

import SwiftUI
struct LanguageView: View {
    @EnvironmentObject var model: EnvironmentModel
    var body: some View {
        Form {
            CustomButton(title: "English", saveTitle: "English")
            CustomButton(title: "Русский", saveTitle: "Russian")
        }
        .navigationBarTitle(model.language == "Russian" ? "Язык" : "Language")
    }
}

struct CustomButton: View {
    @EnvironmentObject var model: EnvironmentModel
    var title: String
    var saveTitle: String
    
    var body: some View {
        HStack {
            Button(action: {
                self.model.language = self.saveTitle
                UserDefaults.standard.set(self.saveTitle, forKey: "Language")
            }) {
                Text(title)
            }
            Spacer()
            if model.language == saveTitle {
                Image("CheckMarkIcon")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
        }
        .onAppear() {
            self.model.language = UserDefaults.standard.string(forKey: "Language") ?? "English"
        }
        .onDisappear() {
            self.model.language = UserDefaults.standard.string(forKey: "Language") ?? ""
        }
    }
}
