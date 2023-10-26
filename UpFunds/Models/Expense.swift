//
//  Expense.swift
//  UpFunds
//
//  Created by Kundo on 25/10/23.
//

import SwiftUI
import SwiftData

@Model
class Expense {
    var note: String
    var subtittle: String?
    var amount: Double
    var date: Date
    var recurrence: Recurrence?

    
    @Relationship(deleteRule: .nullify, inverse: \Wallet.expenses)
    var wallet: Wallet?
    
    @Relationship(deleteRule: .nullify, inverse: \Category.expenses)
    var category: Category?

    

    init(note: String, subtittle: String? = nil, amount: Double, date: Date, recurrence: Recurrence? = nil, wallet: Wallet? = nil, category: Category? = nil) {
        self.note = note
        self.subtittle = subtittle
        self.amount = amount
        self.date = date
        self.recurrence = recurrence
        self.wallet = wallet
        self.category = category
    }

    @Transient
    var currencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        return formatter.string(for: amount) ?? ""
    }
    
    @Transient
    func TotalAmount(array: [Double]) -> Double {
        let sum = array.reduce(0, +)
        return sum
    }
    
    
}
