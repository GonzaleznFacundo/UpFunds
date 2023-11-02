//
//  WalletView.swift
//  UpFunds
//
//  Created by Kundo on 25/10/23.
//
import SwiftUI
import SwiftData

struct WalletView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query private var allWallets: [Wallet]

    @State private var isAlertShowing = false
    @State private var walletName: String = ""
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    
    @State private var walletToEdit: Wallet?

    func handleSubmit() {
        if walletName.count > 0 {
            context.insert(Wallet(walletName: walletName))
            walletName = ""
        } else {
            isAlertShowing = true
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Picker("Select Month", selection: $selectedMonth) {
                        ForEach(1 ..< 13, id: \.self) { month in
                            Text("\(monthName(for: month))")
                                .fixedSize(horizontal: true, vertical: false)
                                .frame(width: 100)
                        }
                    }

                    Picker("Select Year", selection: $selectedYear) {
                        ForEach(2022 ..< 2025, id: \.self) { year in
                            Text("\(year)")
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(width: 100)
                    }
                }
                .padding()

                List {
                    ForEach(allWallets) { wallet in
                        HStack {
                            Text(wallet.walletName)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            context.delete(wallet)
                                        }
                                    } label: {
                                        Label("", systemImage: "trash.fill")
                                    }
                                }
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text("Total:")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .leading)
                                
                                Text(formattedTotalAmount(sumExpenses(expenses: filteredExpensesForSelectedMonthAndYear(walletExpenses: wallet.expenses ?? []))))
                                    .foregroundColor(.green)
                            }
                        } .onTapGesture { walletToEdit = wallet }
                    }
                }

                HStack {
                    ZStack {
                        TextField("Enter title here", text: $walletName)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit { handleSubmit() }
                        
                        if walletName.count > 0 {
                            Button {
                                walletName = ""
                            } label: {
                                Label("Clear input", systemImage: "xmark.circle.fill")
                                    .labelStyle(.iconOnly)
                                    .foregroundColor(.gray)
                                    .padding(.leading, 275)
                            }
                        }
                    }

                    ZStack {
                        Button {
                            withAnimation {
                                handleSubmit()
                            }
                        } label: {
                            Label("Submit", systemImage: "paperplane.fill")
                                .labelStyle(.iconOnly)
                                .padding(6)
                        }
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        .alert("Must provide a wallet name!", isPresented: $isAlertShowing) {
                            Button("Ok", role: .cancel) {}
                        }
                    }
                    .navigationTitle("Wallets")
                    .padding(.horizontal, 16)
                }
                .sheet(item: $walletToEdit) { wallet in
                    UpdateWallet(wallets: wallet)
                        .presentationDetents([.medium, ])
                }
            }
            .onTapGesture { hideKeyboard() }
        }
    }

    func formattedTotalAmount(_ amount: Double) -> String { // Number formatter
        let currencyFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale.current
            return formatter
        }()
        return currencyFormatter.string(from: NSNumber(value: amount)) ?? ""
    }

    func filteredExpensesForSelectedMonthAndYear(walletExpenses: [Expense]) -> [Expense] { //
        return walletExpenses.filter { expense in
            let calendar = Calendar.current
            let expenseComponents = calendar.dateComponents([.month, .year], from: expense.date)
            return expenseComponents.month == selectedMonth && expenseComponents.year == selectedYear
        }
    }

    func monthName(for month: Int) -> String {
        let dateFormatter = DateFormatter()
        return dateFormatter.monthSymbols[month - 1]
    }

    func sumExpenses(expenses: [Expense]) -> Double {
        let amounts = expenses.map { $0.amount }
        return amounts.reduce(0, +)
    }
}

#Preview {
    WalletView()
}

struct UpdateWallet: View {
    @Query private var allWallets: [Wallet]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var isAlertShowing = false
    @State private var walletName: String = ""
    
    @Bindable var wallets: Wallet

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section("Title") {
                        TextField("Title", text: $wallets.walletName   )
                            .submitLabel(.done)
                    }
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
                    Button("Done") { dismiss() }
                }
            }
        }
        .onTapGesture { hideKeyboard() }
    }
}

