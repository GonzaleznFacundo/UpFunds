//
//  SettingsView.swift
//  UpFunds
//
//  Created by Kundo on 25/10/23.
//

import SwiftUI

struct SettingsView: View {
    @State private var isAlertShowing = false
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationView {
            VStack {
                List {
                    HStack {
                        Button(action: {
                            isAlertShowing = true
                        }) {
                            Text("Delete Data")
                        }
                        .foregroundStyle(.red)
                        .alert(isPresented: $isAlertShowing) {
                            Alert(
                                title: Text("Delete Data"),
                                message: Text("Are you sure you want to delete all data?"),
                                primaryButton: .destructive(Text("Delete")) {
                              //      dismiss()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}


#Preview {
        SettingsView()
    }

