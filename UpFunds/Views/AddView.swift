//
//  AddView.swift
//  UpFunds
//
//  Created by Kundo on 25/10/23.
//

import SwiftUI
import SwiftData

struct AddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var wallet: Wallet?
    
    @State private var amount: Double = 0
    @State private var date: Date = .init()
    @State private var note: String = ""
    @State private var subtittle: String = ""

    @State private var category: Category?
    
    @State private var recurrence: Recurrence = Recurrence.none
    
    @Query private var allCategories: [Category]
    @Query private var allWallets: [Wallet]
    
    var dateClosedRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let max = Date()
        return min...max
    }
    
    func handleSubmit() {
        let newExpense = Expense(note: note, subtittle: subtittle, amount: amount, date: date, recurrence: recurrence, wallet: wallet, category: category)
        context.insert(newExpense)
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section("Title") {
                        TextField("Title", text: $note   )
                            .submitLabel(.done)
                        
                    }
                    
                    Section("Amount") {
                        TextField("Amount", value: $amount, formatter: NumFormat)
                            .keyboardType(.decimalPad)
                            .onAppear {
                                amount = 0
                            }
                    }
                    
                    if !allWallets.isEmpty {
                        HStack {
                            Image(systemName: "briefcase.fill")
                                .padding(.horizontal, -3)
                            Text("Wallets")
                            
                            Spacer()
                            
                            Menu {
                                ForEach(allWallets) { wallet in
                                    Button(wallet.walletName) {
                                        self.wallet = wallet
                                    }
                                }
                                
                                Button("None") {
                                    wallet = nil
                                }
                            } label: {
                                if let walletName = wallet?.walletName {
                                    Text(walletName)
                                } else {
                                    Text("None")
                                }
                            }
                        }
                    }
                    
                    if !allCategories.isEmpty {
                        HStack {
                            Image(systemName: "tag.fill")
                                .padding(.horizontal, -3)
                            Text("Category")
                            
                            Spacer()
                            
                            Menu {
                                ForEach(allCategories) { category in
                                    Button(category.categoryName) {
                                        self.category = category
                                    }
                                }
                                
                                Button("None") {
                                    category = nil
                                }
                            } label: {
                                if let categoryName = category?.categoryName {
                                    Text(categoryName)
                                } else {
                                    Text("None")
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .padding(.horizontal, -2)
                        Text("Date")
                        DatePicker(
                            selection: $date,
                            in: dateClosedRange,
                            displayedComponents: .date,
                            label: { Text("") }
                        )
                    }
                    
                    HStack {
                        Image(systemName: "repeat")
                            .padding(.horizontal, -3)
                        Text("Recurrence")
                        Picker(selection: $recurrence, label: Text(""), content: {
                            Text("None").tag(Recurrence.none)
                            Text("Daily").tag(Recurrence.daily)
                            Text("Weekly").tag(Recurrence.weekly)
                            Text("Monthly").tag(Recurrence.monthly)
                            Text("Yearly").tag(Recurrence.yearly)
                        })
                    }
                }
                .navigationTitle("Add")
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard ) {
                        Spacer()
                        Button {
                            hideKeyboard()
                        } label: {
                            Text("Done")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add", action: handleSubmit)
                            .disabled(addButtonDisabled)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .tint(.red)
                    }
                }
                
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onTapGesture { hideKeyboard() }
        }
    }
    
    var NumFormat: NumberFormatter {
        let NumFormat = NumberFormatter()
        NumFormat.numberStyle = .decimal
        NumFormat.maximumFractionDigits = 2
        return NumFormat
    }
    
    var addButtonDisabled: Bool {
        return note.isEmpty || amount == .zero
    }
}

#Preview {
    AddView()
}


struct UpdateExpenses: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var amount: Double = 0
    @State private var date: Date = .init()
    @State private var note: String = ""
    @State private var subtittle: String = ""
    
    @State private var category: Category?
    @State private var recurrence: Recurrence = Recurrence.none
    
    @Query private var allCategories: [Category]
    @Query private var allWallets: [Wallet]
    
    @State private var wallet: Wallet?
    
    @State private var isInitialLoad = true
    @State private var isInitialLoad2 = true

    @Bindable var expense: Expense
    
    var dateClosedRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let max = Date()
        return min...max
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section("Title") {
                        TextField("Title", text: $expense.note)
                            .submitLabel(.done)
                    }
                    
                    Section("Amount") {
                        TextField("Amount", value: $expense.amount, format: .currency(code: ""))
                            .keyboardType(.decimalPad)
                    }
                    
                    if !allWallets.isEmpty {
                        HStack {
                            Image(systemName: "briefcase.fill")
                                .padding(.horizontal, -3)
                            Text("Wallets")
                            
                            Spacer()
                            
                            Menu {
                                ForEach(allWallets) { wallet in
                                    Button(wallet.walletName) {
                                        self.wallet = wallet
                                        expense.wallet = wallet
                                    }
                                }
                                
                                Button("None") {
                                    wallet = nil
                                    expense.wallet = nil
                                }
                            } label: {
                                Text(wallet?.walletName ?? "None")
                            }
                        }
                        .onAppear {
                            if isInitialLoad {
                                wallet = expense.wallet
                                isInitialLoad = false
                            }
                        }
                    }

                    if !allCategories.isEmpty {
                        HStack {
                            Image(systemName: "tag.fill")
                                .padding(.horizontal, -3)
                            Text("Categories")
                            
                            Spacer()
                            
                            Menu {
                                ForEach(allCategories) { category in
                                    Button(category.categoryName) {
                                        self.category = category
                                        expense.category = category
                                    }
                                }
                                Button("None") {
                                    category = nil
                                    expense.category = nil
                                }
                            } label: {
                                if let categoryName = category?.categoryName {
                                    Text(categoryName)
                                } else {
                                    Text("None")
                                }
                            }
                        }
                        .onAppear {
                            if isInitialLoad2 {
                                category = expense.category
                                isInitialLoad2 = false
                            }
                        }
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .padding(.horizontal, -2)
                        Text("Date")
                        DatePicker(
                            selection: $expense.date,
                            in: dateClosedRange,
                            displayedComponents: .date,
                            label: { Text("") }
                        )
                    }
                    
                    HStack {
                        Image(systemName: "repeat")
                            .padding(.horizontal, -3)
                        Text("Recurrence")
                        Picker(selection: $expense.recurrence, label: Text(""), content: {
                            Text("None").tag(Recurrence.none)
                            Text("Daily").tag(Recurrence.daily)
                            Text("Weekly").tag(Recurrence.weekly)
                            Text("Monthly").tag(Recurrence.monthly)
                            Text("Yearly").tag(Recurrence.yearly)
                        })
                    }
                }
                .navigationTitle("Edit")
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard ) {
                        Spacer()
                        Button {
                            hideKeyboard()
                        } label: {
                            Text("Done")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}


