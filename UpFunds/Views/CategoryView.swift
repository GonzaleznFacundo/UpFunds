
import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query private var allCategories: [Category]

    @State private var isAlertShowing = false
    @State private var categoryName: String = ""
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    
    @State private var categoryToEdit: Category?

    func handleSubmit() {
        if categoryName.count > 0 {
            context.insert(Category(categoryName: categoryName))
            categoryName = ""
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
                        ForEach(2022 ..< 2030, id: \.self) { year in
                            Text("\(year)")
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(width: 100)
                    }
                }
                .padding()

                List {
                    ForEach(allCategories) { category in
                        HStack {
                            Text(category.categoryName)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            context.delete(category)
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
                                
                                Text(formattedTotalAmount(sumExpenses(expenses: filteredExpensesForSelectedMonthAndYear(categoryExpenses: category.expenses ?? []))))
                                    .foregroundColor(.green)
                            }
                        } .onTapGesture { categoryToEdit = category }
                    }
                }

                HStack {
                    ZStack {
                        TextField("Enter title here", text: $categoryName)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit { handleSubmit() }
                        
                        if categoryName.count > 0 {
                            Button {
                                categoryName = ""
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
                        .alert("Must provide a category name!", isPresented: $isAlertShowing) {
                            Button("Ok", role: .cancel) {}
                        }
                    }
                    .navigationTitle("Categories")
                    .padding(.horizontal, 16)
                }
                .sheet(item: $categoryToEdit) { category in
                    UpdateCategories(categories: category)
                        .presentationDetents([.medium, ])
                }
            }
            .onTapGesture { hideKeyboard() }
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

    func filteredExpensesForSelectedMonthAndYear(categoryExpenses: [Expense]) -> [Expense] {
        return categoryExpenses.filter { expense in
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
    CategoriesView()
}

struct UpdateCategories: View {
    @Query private var allCategories: [Category]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var isAlertShowing = false
    @State private var categoryName: String = ""
    
    @Bindable var categories: Category

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section("Title") {
                        TextField("Title", text: $categories.categoryName   )
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
