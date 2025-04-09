//
//  TaskCard.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-09.
//

import SwiftUI

struct TaskCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let count: Int
    
    var body: some View {
        Rectangle()
            .fill(Color.OffWhite)
            .cornerRadius(24)
            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.09)
            .overlay(
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(iconColor.opacity(0.2))
                        )
                        .padding()
                    
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.title3)
                            .bold()
                        Text(subtitle)
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Text("\(count)")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(iconColor)
                        .padding(.trailing, 20)
                }
            ).padding(.bottom, 20)
    }
}

#Preview {
    TaskCard(icon: "house", iconColor: Color.blue, title: "Title", subtitle: "This is title", count: 12)
}
