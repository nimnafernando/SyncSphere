//
//  TaskCategoryCardView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-05-06.
//

import SwiftUI

struct TaskCategoryCardView: View {
    let category: SyncTaskCategory
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            Spacer()
            Image(systemName: iconForCategory(category.name))
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .foregroundColor(Color(hex: category.color ?? "#7D5FFF"))
                .padding(.trailing, 8)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.95))
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(action: { onEdit?() }) {
                Image(systemName: "pencil")
            }
            .tint(Color.blue.opacity(0.3))
            Button(role: .destructive, action: { onDelete?() }) {
                Image(systemName: "trash")
            }
        }
    }

    func iconForCategory(_ name: String) -> String {
        let lower = name.lowercased()
        if lower.contains("food") { return "takeoutbag.and.cup.and.straw" }
        if lower.contains("flower") { return "flower" }
        if lower.contains("deco") { return "sparkles" }
        return "tray.full"
    }
}

#Preview {
    VStack(spacing: 16) {
        TaskCategoryCardView(category: SyncTaskCategory(name: "Food & Beverage", color: "#A084E8", createdBy: "user123"))
        TaskCategoryCardView(category: SyncTaskCategory(name: "Flowers", color: "#F7C8E0", createdBy: "user123"))
        TaskCategoryCardView(category: SyncTaskCategory(name: "Decorations", color: "#B6E2A1", createdBy: "user123"))
    }
    .padding()
    .background(
        LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.yellow.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
    )
} 
