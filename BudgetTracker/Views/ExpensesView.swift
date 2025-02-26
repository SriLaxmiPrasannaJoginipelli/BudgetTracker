//
//  ExpensesView.swift
//  BudgetTracker
//
//  Created by Srilu Rao on 2/19/25.
//

import SwiftUI
import Charts


struct ExpensesView: View {
    @StateObject var viewModel : TransactionViewModel
    @State var showAddExpenseView = false
    @State var deleteExpense = false
    @State private var showAlertForBudget = false
    @State private var outOfBudget = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                // Total Expenses Section
                VStack {
                    Text("Total Expenses")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("-$\(viewModel.totalExpenses, specifier: "%.2f")")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    if let highestCategory = viewModel.highestExpenseCategory {
                        Text("Highest Spending: \(highestCategory)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.red.gradient))
                .padding(.horizontal)
                
                // Expense Breakdown Chart
                if viewModel.expenseBreakdown.isEmpty {
                    Text("No expenses data available.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ExpensesBarChart(data: viewModel.expenseBreakdown)
                        .frame(height: 250)
                        .padding(.horizontal)
                }
                
                // Recent Expenses Section
                VStack {
                    HStack {
                        Text("Recent Expenses")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        Button(action: {
                            deleteExpense.toggle()
                        }) {
                            Text("Edit")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 70, height: 50)
                                .background(viewModel.transactions.isEmpty ? Color.gray : Color.red)
                                .cornerRadius(25)
                        }
                        .disabled(viewModel.transactions.isEmpty)
                        .padding(.trailing)
                        .sheet(isPresented: $deleteExpense) {
                            DeleteExpenseView(viewModel: viewModel)
                        }
                    }
                    .padding(.top)
                    
                    if !viewModel.transactions.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.transactions.filter { $0.type == "expense" }.prefix(4), id: \.id) { entry in
                                    ExpenseCard(category: entry.category, amount: entry.amount)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Spacer to push button to the bottom
                Spacer()
                
                // Add Expense Button
                Button(action: {
                    showAddExpenseView.toggle()
                }) {
                    Text("Add Expense")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .sheet(isPresented: $showAddExpenseView) {
                    AddExpenseView(viewModel: viewModel)
                }
            }
            .onAppear {
                outOfBudget = viewModel.remainingBudget() < 0
                showAlertForBudget = viewModel.showAlertForBudget
            }
            .alert(isPresented: $showAlertForBudget) {
                Alert(
                    title: Text("Warning"),
                    message: Text(outOfBudget ? "You are out of budget!" : "You're about to run out of budget!"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationBarItems(trailing: AddBudgetView(viewModel: viewModel))
            .navigationTitle("Expenses")
            .padding(.top)
        }
    }
}


struct ExpenseCard: View {
    var category: String
    var amount: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(category)
                .font(.headline)
            Text("-$\(amount, specifier: "%.2f")")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 130, height: 80)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
    }
}

struct DeleteExpenseView: View {
    @ObservedObject var viewModel: TransactionViewModel
    
    var body: some View {
        VStack {
            Text("Manage Your Expenses")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            List {
                ForEach(viewModel.transactions.filter { $0.type == "expense" }, id: \.id) { entry in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(entry.category)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                        
                        Text("-$\(entry.amount, specifier: "%.2f")") // Format the amount nicely
                            .font(.body)
                            .fontWeight(.regular)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                }
                .onDelete { indexSet in
                    viewModel.deleteExpense(at: indexSet)
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}

struct AddExpenseView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var expenseAmount: String = ""
    @State private var expenseCategory: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                TextField("Expense Amount", text: $expenseAmount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                TextField("Expense Category", text: $expenseCategory)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Button(action: addExpense) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Expense")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                viewModel.remainingBudget()
            }
        }
    }
    
    private func addExpense() {
        guard let amount = Double(expenseAmount), !expenseCategory.isEmpty else { return }
        viewModel.addExpense(amount: amount, category: expenseCategory)
        presentationMode.wrappedValue.dismiss()
    }
}

struct ExpensesBarChart: View {
    var data: [String: Double]
    
    var body: some View {
        Chart {
            ForEach(data.sorted(by: { $0.value > $1.value }), id: \.key) { category, amount in
                BarMark(
                    x: .value("Category", category),
                    y: .value("Amount", amount)
                )
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [Color.red, Color.red.opacity(0.5)]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisValueLabel()
                AxisGridLine()
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom) {
                AxisValueLabel()
                AxisGridLine()
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white).shadow(radius: 4))
    }
}

struct AddBudgetView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var showAddBudgetSheet = false
    var body: some View {
        Button(action: {
            // Action to handle budget addition
            showAddBudgetSheet = true
            print("Add Budget tapped")
        }) {
            VStack {
                Text("Add Budget")
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundColor(.white)
                
//                Text("\(String(describing: currentMonth()))")
//                    .font(.headline)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
            }
            .padding()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange.opacity(0.7)]), startPoint: .leading, endPoint: .trailing)
        )
        .cornerRadius(25)
        .frame(height: 50)
        .shadow(radius: 10)
        .sheet(isPresented: $showAddBudgetSheet) {
            
            AddMonthBudgetView(viewModel: viewModel)
        }
        
    }
    
    private func currentMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
}

