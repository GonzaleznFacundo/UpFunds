//
//  ExpensesView.swift
//  UpFunds
//
//  Created by Kundo on 25/10/23.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    @Query(sort: [SortDescriptor(\Expense.date, order: .reverse)])
    private var allExpenses: [Expense]
    @Environment(\.modelContext) private var context

    @State private var groupedExpenses: [GroupedExpense] = []
    @State private var originalgroupedExpenses: [GroupedExpense] = []
    @State private var searchText: String = ""
    @State private var addExpense: Bool = false
    @State private var expenseToEdit: Expense?

    var body: some View {
        NavigationStack {
            VStack {
                if searchText.isEmpty {
                    TotalExpenseList(expense: allExpenses)
                }
                List {
                    ForEach($groupedExpenses) { $group in
                        Section(group.groupTitle) {
                            ForEach(group.expenses) { expense in
                                ExpensesList(expense: expense)
                                    .onTapGesture {
                                        expenseToEdit = expense
                                    }

                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button {
                                            context.delete(expense)
                                            withAnimation {
                                                group.expenses.removeAll(where: { $0.id == expense.id })

                                                if group.expenses.isEmpty {
                                                    groupedExpenses.removeAll(where: { $0.id == group.id })
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                        .tint(.red)
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addExpense.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: Text("Search"))
            .overlay {
                if allExpenses.isEmpty || groupedExpenses.isEmpty {
                    ContentUnavailableView {
                        Label("No Expenses", systemImage: "tray.fill")
                    }
                }
            }
            .onChange(of: searchText, initial: false) { oldValue, newValue in
                if !newValue.isEmpty {
                    filterExpenses(newValue)
                } else {
                    groupedExpenses = originalgroupedExpenses
                }
            }
            .onChange(of: allExpenses, initial: true) { oldValue, newValue in
                if newValue.count > oldValue.count || groupedExpenses.isEmpty {
                    createGroupedExpenses(newValue)
                }
            }
            .sheet(isPresented: $addExpense) { AddView() }
            .sheet(item: $expenseToEdit) { expense in
                UpdateExpenses(expense: expense)
            }
        }
    }

    func filterExpenses(_ text: String) {
        Task.detached(priority: .high) {
            let query = text.lowercased()
            let filteredExpenses = originalgroupedExpenses.compactMap { group -> GroupedExpense? in
                let expenses = group.expenses.filter { expense in
                    let containsInNote = expense.note.lowercased().contains(query)
                    let containsInCategory = expense.category?.categoryName.lowercased().contains(query) ?? false
                    let containsInWallet = expense.wallet?.walletName.lowercased().contains(query) ?? false

                    return containsInNote || containsInCategory || containsInWallet
                }

                if expenses.isEmpty {
                    return nil
                }

                return .init(date: group.date, expenses: expenses)
            }

            await MainActor.run {
                groupedExpenses = filteredExpenses
            }
        }
    }

    func createGroupedExpenses(_ expenses: [Expense]) {
        Task.detached(priority: .high) {
            let groupedDict = Dictionary(grouping: expenses) { expense in
                let dateComponent = Calendar.current.dateComponents([.day, .month, .year], from: expense.date)

                return dateComponent
            }

            let sortedDict = groupedDict.sorted {
                let calendar = Calendar.current
                let date1 = calendar.date(from: $0.key) ?? .init()
                let date2 = calendar.date(from: $1.key) ?? .init()

                return calendar.compare(date1, to: date2, toGranularity: .day) == .orderedDescending
            }

            await MainActor.run {
                groupedExpenses = sortedDict.compactMap({ dict in
                    let date = Calendar.current.date(from: dict.key) ?? .init()
                    return .init(date: date, expenses: dict.value)
                })
                originalgroupedExpenses = groupedExpenses
            }
        }
    }
}

#Preview {
    ExpensesView()
}
