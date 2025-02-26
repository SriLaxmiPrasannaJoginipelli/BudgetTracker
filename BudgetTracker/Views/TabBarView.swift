//
//  TabBarView.swift
//  BudgetTracker
//
//  Created by Srilu Rao on 2/19/25.
//

import SwiftUI
import Charts

struct TabBarView: View {
    @StateObject private var viewModel = TransactionViewModel()
    
    var body : some View{
        
        TabView{
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            IncomeView(viewModel: viewModel)
                .tabItem {
                    Label("Income", systemImage: "dollarsign.circle.fill")
                }
            ExpensesView(viewModel: viewModel)
                .tabItem {
                    Label("Expenses", systemImage: "cart.fill")
                }
            RecurringTransactionsView(viewModel: viewModel)
                .tabItem {
                    Label("Recurring", systemImage: "repeat")
                }
        }
        
    }
    
}
#Preview {
    
}
