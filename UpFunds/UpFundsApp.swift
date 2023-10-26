//
//  UpFundsApp.swift
//  UpFunds
//
//  Created by Kundo on 25/10/23.
//

import SwiftUI

@main
struct UpFundsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        .modelContainer(for: [Expense.self, Category.self, Wallet.self])
    }
}
