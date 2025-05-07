//
//  AllTaskCategoryView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-04-11.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = 36.0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct AllTaskCategoryView: View {
    @StateObject var viewModel = TaskCategoryViewModel()
    @State private var showAddSheet = false
    @State private var editingCategory: SyncTaskCategory? = nil
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(alignment: .leading, spacing: 0) {
                Text(NSLocalizedString("event_task_categories_header_text", comment: ""))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                if viewModel.categories.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.7))
                        Text("No categories yet")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 18) {
                            ForEach(viewModel.categories) { category in
                                TaskCategoryCardView(category: category)
                                    .padding(.horizontal, 8)
                                    .onTapGesture {
                                        editingCategory = category
                                    }
                            }
                        }
                        .padding(.top, 20)
                    }
                }
            }
            .background(Color.clear)
            .scrollContentBackground(.hidden)
            .onAppear {
                viewModel.fetchAllTaskCategories()
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .padding(22)
                            .background(
                                Circle()
                                    .fill(Color.lavendar)
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddNewTaskCategorySheet {
                showAddSheet = false
                viewModel.fetchAllTaskCategories()
            }
            .presentationDetents([.height(350)])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $editingCategory) { category in
            let palette = ["#7D5FFF", "#3ED598", "#5CE1E6", "#FFE066", "#F7C8E0", "#FF6B6B"]
            let initialColor = category.color
                .flatMap { color in
                    palette.first { $0.caseInsensitiveCompare(color.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame }
                } ?? palette[0]
            EditTaskCategorySheet(
                name: category.name,
                selectedColor: initialColor,
                category: category
            ) {
                editingCategory = nil
                viewModel.fetchAllTaskCategories()
            }
            .presentationDetents([.height(350)])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    AllTaskCategoryView()
}

