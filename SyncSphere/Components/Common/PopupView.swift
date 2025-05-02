//
//  PopupView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-30.
//

import SwiftUI

struct PopupView<Content: View>: View {
    let title: String
    let message: String
    let isPresented: Binding<Bool>
    let onConfirm: (() -> Void)?
    let onCancel: (() -> Void)?
    let confirmButtonTitle: String
    let cancelButtonTitle: String
    let content: Content

    init(
        title: String = "Confirm",
        message: String = "Are you sure?",
        isPresented: Binding<Bool>,
        confirmButtonTitle: String = "OK",
        cancelButtonTitle: String = "Cancel",
        onConfirm: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) {
        self.title = title
        self.message = message
        self.isPresented = isPresented
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        self.confirmButtonTitle = confirmButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.content = content()
    }

    var body: some View {
        if isPresented.wrappedValue {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented.wrappedValue = false
                    }

                VStack(spacing: 20) {
                    Text(title)
                        .font(.headline)

                    Text(message)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)

                    content

                    HStack(spacing: 20) {
                        Button(cancelButtonTitle) {
                            onCancel?()
                            isPresented.wrappedValue = false
                        }
                        .foregroundColor(.gray)
                        .padding(.trailing, 10)
                        
                        Button(confirmButtonTitle) {
                            onConfirm?()
                            isPresented.wrappedValue = false
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    StatefulPreviewWrapper(true) { binding in
        PopupView(
            title: "Test Popup", message: "This is a preview popup.", isPresented: binding,
            confirmButtonTitle: "Confirm",
            cancelButtonTitle: "Dismiss"
        )
    }
}

import SwiftUI

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}


