//
//  TaskDetailView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-04-11.
//

import SwiftUI

struct TaskDetailView: View {
    @StateObject var viewModel = TaskCategoryViewModel()
    
    var body: some View {
        
        List(viewModel.categories) { category in
            Text(category.name)
        }.onAppear {
            viewModel.fetchAllTaskCategories()
        }


    }
}

#Preview {
    TaskDetailView()
}
