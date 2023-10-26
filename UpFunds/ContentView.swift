//
//  ContentView.swift
//  UpFunds
//
//  Created by Kundo on 25/10/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    var body: some View {
        
            TabView {
                ExpensesView()
                    .tabItem {
                        Label("Expenses", systemImage: "house")
                        
                    }
                WalletView()
                    .tabItem {
                        Label("Wallets", systemImage: "briefcase")
                        
                    }
                CategoriesView()
                    .tabItem {
                        Label("Categories", systemImage: "list.bullet.clipboard.fill")
                        
                    }

                SettingsView()
                    .tabItem {
                        Label("Setting", systemImage: "text.justify")
                    }
                
            }
        }
    }


#Preview {
    ContentView()
    }


