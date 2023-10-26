//
//  Wallet.swift
//  UpFunds
//
//  Created by Kundo on 25/10/23.
//

import SwiftUI
import SwiftData

@Model
class Wallet {
  //  @Attribute(.unique)
    var walletName: String
    
    var expenses: [Expense]?

    init(walletName: String) {
        self.walletName = walletName
    }
}
