//
//  AddNewTaskCategorySheet.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-05-06.
//

import SwiftUI

struct AddNewTaskCategorySheet: View {
    @State private var name: String = ""
    @State private var selectedColor: String = "#7D5FFF"
    @StateObject private var viewModel = TaskCategoryViewModel()
    @Environment(\.dismiss) private var dismiss

    let colors: [String] = ["#7D5FFF", "#3ED598", "#5CE1E6", "#FFE066", "#F7C8E0", "#FF6B6B"]
    var onSave: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()
                Text("Add Task Category")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black.opacity(0.7))
                }
            }
            .padding(.top, 16)
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Category Name")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                    TextField("Category Name", text: $name)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding(.vertical, 6)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.2))
                }

                VStack(alignment: .leading, spacing: 20) {
                    Text("Category Color")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                    HStack(spacing: 18) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.black : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture { selectedColor = color }
                        }
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            Button(action: {
                guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                viewModel.addTaskCategory(name: name, color: selectedColor, createdBy: "userId_123")
                dismiss()
                onSave?()
            }) {
                Text("Save")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#7D5FFF"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(
            Color.white
                .clipShape(RoundedCorner(radius: 36, corners: [.topLeft, .topRight]))
                .ignoresSafeArea()
        )
    }
}

#Preview {
    AddNewTaskCategorySheet()
}
