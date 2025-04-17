//
//  AllTaskCategoryView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-04-11.
//

import SwiftUI

struct AllTaskCategoryView: View {
    
    @StateObject var viewModel = TaskCategoryViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Event Categories")
                .font(.title3)
                .padding()
            
            List(viewModel.categories) { category in
                let categoryColor = category.color ?? "#3498DB"
                TaskCard(
                    icon: "tray.full",
                    iconColor: Color(hex: categoryColor),
                    title: category.name,
                    subtitle: "",
                    count: 0
                )
            }.onAppear {
                viewModel.fetchAllTaskCategories()
            }
        }
        Spacer()
        
        HStack{
             Spacer()
            NavigationLink(destination: AddNewTaskCategoryView()) {
                Image(systemName: "plus")
                    .font(.system(size: 28))
                    .foregroundColor(Color.white)
                    .padding(20)
                    .background(
                        Circle()
                            .fill(Color.Lavendar)
                    )
                    .padding(.trailing, 20)
            }

        }
    }
}

#Preview {
    AllTaskCategoryView()
}
