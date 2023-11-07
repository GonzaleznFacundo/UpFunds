//
//  ExpensesList.swift
//  UpFunds
//
//  Created by Kundo on 25/10/23.
//

import SwiftUI

struct ExpensesList: View {
    @Bindable var expense: Expense
    var displayTag: Bool = true
    

    var body: some View {
        HStack {
            VStack(alignment: .leading) { 
                Text(expense.note)
                    .foregroundStyle(.white)
                HStack {
                
                if let walletName = expense.wallet?.walletName, displayTag {
                    Text(walletName)
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 4)
                        .background(.red.opacity(0.4), in : .capsule)
                    
                }
                
                if let category = expense.category?.categoryName, displayTag {
                    Text(category)
                        .font(.caption2)
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.4), in : .capsule)
                    }
                }
            }
            .lineLimit(1)
            
            Spacer(minLength: 6)
            
            Text(expense.currencyString)
                .font(.title3.bold())
                .padding(.bottom, 4)

            }
        }
    }

