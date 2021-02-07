//
//  CreateIconView.swift
//  Budget
//
//  Created by Nicholas HwanG on 1/4/20.
//  Copyright © 2020 Hwang. All rights reserved.
//

import SwiftUI
import CoreData

struct CreateIconView: View {
    @EnvironmentObject var model: EnvironmentModel
    @State private var imageArray: [[String]] = [
        ["HomeIcon", "PigIcon","CarIcon","CaseIcon","ClothesIcon"],
        ["FoodIcon","HealthIcon","LendMoneyIcon","PartyIcon","StudyIcon"],
        ["AirplaneIcon","CoupleIcon","DeathIcon","FamilyIcon","GymIcon"],
        ["HumanIcon","MusicIcon","PalmIcon","PetIcon","RepairIcon"]]
    
    @State private var colorArray: [[String]] = [
        ["Red","Green","Blue","Orange","Yellow","Brown","Pink"],
        ["Purple","Teal","Indigo","Gray"]
    ]
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var context
    @State private var selectedImage = "HomeIcon"
    @State private var selectedColor = "Red"
    
    
    private func addIcon() {
        let icon = NSEntityDescription.insertNewObject(forEntityName: "Icon", into: context)
        icon.setValue(selectedImage, forKey: "image")
        icon.setValue(selectedColor, forKey: "color")
        icon.setValue(Date(), forKey: "date")
        
        do {
            try context.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            // handle the Core Data error
        }
    }
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Rectangle()
                    .foregroundColor(Color(UIColor(named: selectedColor)!))
                    .frame(width: 80, height: 80)
                    .cornerRadius(20)
                Image(selectedImage)
                    .resizable()
                    .frame(width: 110, height: 110)
            }
            VStack(spacing: 12) {
                ForEach(colorArray, id: \.self) { array in
                    HStack(spacing: 12) {
                        ForEach(array, id: \.self) { color in
                            Button(action: {
                                self.selectedColor = color
                            }) {
                                Color(UIColor(named: color)!)
                            }
                            .frame(width: 40, height: 40)
                            .cornerRadius(10)
                            .scaleEffect(self.selectedColor == color ? 1.43 : 1)
                        }
                    }
                }
            }
            VStack {
                ForEach(imageArray, id: \.self) { array in
                    HStack {
                        ForEach(array, id: \.self) { image in
                            Button(action: {
                                self.selectedImage = image
                            }) {
                                Image(image)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .scaleEffect(self.selectedImage == image ? 1.43 : 1)
                            }
                        }
                    }
                }
            }
            .background(Color.gray)
            .cornerRadius(12)
            
            Button(action: {
                self.addIcon()
            }) {
                Text(model.language == "Russian" ? "Создать" : "Create")
            }
            Text(model.language == "Russian" ? "Удерживайте значок две секунды, чтобы удалить его." : "Hold the icon two seconds to delete it.")
                .foregroundColor(Color.gray)
                .font(.system(size: 14))
        }
        .animation(.spring())
    }
}
