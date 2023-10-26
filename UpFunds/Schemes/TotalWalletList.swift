//
//  TotalWalletList.swift
//  UpFunds
//
//  Created by Kundo on 25/10/23.
//

import SwiftUI
import SwiftData

struct TotalWalletList: View {
    var expenses: [Expense]
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        VStack {
            // Picker to control month and year
            HStack {
                Picker("Select Month", selection: $selectedMonth) {
                    ForEach(1 ..< 13, id: \.self) { month in
                        Text("\(monthName(for: month))")
                            .fixedSize(horizontal: true, vertical: false)
                            .frame(width: 100)
                    }
                }

                Picker("Select Year", selection: $selectedYear) {
                    ForEach(2022 ..< 2030, id: \.self) { year in
                        Text("\(year)")
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(width: 100)
                }
            }
            .padding()

            // Display total amount for all wallets
            Text("Total Amount:")
                .font(.headline)
            Text(formattedTotalAmount(sumExpenses(expenses: expensesForSelectedMonthAndYear())))
                .foregroundColor(.blue)
        }
    }

    func formattedTotalAmount(_ amount: Double) -> String {
        let currencyFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale.current
            return formatter
        }()
        return currencyFormatter.string(from: NSNumber(value: amount)) ?? ""
    }

    func expensesForSelectedMonthAndYear() -> [Expense] {
        return expenses.filter { expense in
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

