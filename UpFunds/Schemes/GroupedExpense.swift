//
//  GroupedExpense.swift
//  UpFunds
//
//  Created by Kundo on 25/10/23.
//

import SwiftUI
import SwiftData


struct GroupedExpense: Identifiable {
    var id: UUID = .init()
    var date: Date
    var expenses: [Expense]
    
    
    var groupTitle: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
                return "Today"
        } else if calendar.isDateInYesterday(date) {
                return "Yesterday"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }
}

