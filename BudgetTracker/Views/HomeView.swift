//
//  HomeView.swift
//  BudgetTracker
//
//  Created by Srilu Rao on 2/19/25.
//

import SwiftUI
import Foundation
import Charts

enum TransactionType: String {
    case income = "income"
    case expense = "expense"
}

struct HomeView: View {
    @ObservedObject var viewModel: TransactionViewModel
    
    var chartData: [(category: String, amount: Double, color: Color)] {
            return [
                ("Income", viewModel.totalIncome, .green),
                ("Expenses", viewModel.totalExpenses, .red)
            ]
        }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Overview")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 10) {
                    Text("Balance: $\(viewModel.balance, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.balance >= 0 ? .green : .red)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemBackground)).shadow(radius: 5))
                
                Chart {
                    ForEach(chartData, id: \..category) { data in
                        SectorMark(
                            angle: .value("Amount", data.amount),
                            innerRadius: .ratio(0.6),
                            outerRadius: .ratio(1.0)
                        )
                        .foregroundStyle(data.color)
                    }
                }
                .frame(height: 300)
                .padding()
                
                HStack(spacing: 30) {
                    VStack {
                        Text("Total Income")
                            .font(.headline)
                            .foregroundColor(.green)
                        Text("$\(viewModel.totalIncome, specifier: "%.2f")")
                            .font(.title3)
                    }
                    VStack {
                        Text("Total Expenses")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text("$\(viewModel.totalExpenses, specifier: "%.2f")")
                            .font(.title3)
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
        .onAppear {
            viewModel.fetchTransactions()
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            Text(transaction.category)
                .font(.headline)
            Spacer()
            Text("$\(transaction.amount, specifier: "%.2f")")
                .foregroundColor(transaction.type == TransactionType.expense.rawValue ? .red : .green)
        }
        .padding(.vertical, 5)
    }
}

//#Preview {
//    HomeView()
//}
