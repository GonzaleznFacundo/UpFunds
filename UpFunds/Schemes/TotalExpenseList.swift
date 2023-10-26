//
//  TotalExpenseList.swift
//  UpFunds
//
//  Created by Kundo on 25/10/23.
//

import SwiftUI
import SwiftData

struct TotalExpenseList: View {
    var expense: [Expense]
    
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        VStack {
            // Month and Year Picker
            HStack {
                Picker("Select Month", selection: $selectedMonth) {
                    ForEach(1 ..< 13, id: \.self) { month in
                        Text("\(monthName(for: month))")
                    }
                }
                .frame(width: 135)
                .padding(.trailing, 90)
                .padding(.top, 50)
                
                Picker("Select Year", selection: $selectedYear) {
                    ForEach(2022 ..< 2030, id: \.self) { year in
                        Text("\(year)")
                    }
                }
                .frame(width: 90)
                .padding(.leading, 40)
                .padding(.top, 50)
            }
            
            VStack {
                let filteredExpenses = filterExpenses(by: selectedMonth, year: selectedYear, expenses: expense)
                let totalAmountForSelectedMonth = sumExpenses(expenses: filteredExpenses)
                
                let currencyFormatter: NumberFormatter = {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    formatter.locale = Locale.current
                    return formatter
                }()
                
                if let formattedTotalAmount = currencyFormatter.string(from: NSNumber(value: totalAmountForSelectedMonth)) {
                    Text("Total for \(monthName(for: selectedMonth)):")
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(width: 140)
                        .font(.title3.bold())

                    Text("\(formattedTotalAmount)")
                        .font(.title3.bold())
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.bottom, 4)
                }
            }
            .padding(.bottom, 70)
        }
        .frame(maxWidth: 350, maxHeight: 130)
        .padding(1)
        .background(Color("Color.Box"))
        .cornerRadius(9)
    }

    
    func monthName(for month: Int) -> String {
        let dateFormatter = DateFormatter()
        return dateFormatter.monthSymbols[month - 1]
    }

    func filterExpenses(by month: Int, year: Int, expenses: [Expense]) -> [Expense] {
        let filteredExpenses = expenses.filter { expense in
            let calendar = Calendar.current
            let expenseComponents = calendar.dateComponents([.month, .year], from: expense.date)
            return expenseComponents.month == month && expenseComponents.year == year
        }
        return filteredExpenses
    }

    func sumExpenses(expenses: [Expense]) -> Double {
        let amounts = expenses.map { $0.amount }
        let totalAmount = amounts.reduce(0, +)
        return totalAmount
    }
}
