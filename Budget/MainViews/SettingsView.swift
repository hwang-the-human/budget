//
//  SettingsView.swift
//  Budget
//
//  Created by Nicholas HwanG on 1/12/20.
//  Copyright © 2020 Hwang. All rights reserved.
//

import SwiftUI
struct SettingsView: View {
    @EnvironmentObject var model: EnvironmentModel
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: LanguageView()) {
                        Text(model.language == "Russian" ? "Язык" : "Language")
                    }
                }
                Section {
                    Text(model.language == "Russian" ? "Синхронизация - Скоро!" : "Synchronization - Soon!")
                }
            }
            .navigationBarTitle(model.language == "Russian" ? "Настройки" : "Settings")
        }
    }
}
