//
//  FloatingActionButton.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-18.
//

import SwiftUI

import SwiftUI

struct FloatingActionButton<Destination: View>: View {
    let destination: Destination
    let iconName: String
    let backgroundColor: Color

    init(destination: Destination, iconName: String = "plus", backgroundColor: Color = .Lavendar) {
        self.destination = destination
        self.iconName = iconName
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        HStack {
            Spacer()
            NavigationLink(destination: destination) {
                Image(systemName: iconName)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .padding(20)
                    .background(
                        Circle()
                            .fill(backgroundColor)
                    )
                    .padding(.trailing, 20)
            }
        }
    }
}

