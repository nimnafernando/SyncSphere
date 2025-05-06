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
                            }
                        }
                        .padding(.top, 20)
                    }
                }
            }
            .onAppear {
                viewModel.fetchAllTaskCategories()
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(22)
                            .background(
                                Circle()
                                    .fill(Color(hex: "#7D5FFF"))
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
    }
}

#Preview {
    AllTaskCategoryView()
}

