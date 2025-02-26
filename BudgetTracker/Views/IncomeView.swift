//
//import SwiftUI
//import Charts


import SwiftUI
import Charts

struct IncomeView: View {
    @StateObject var viewModel : TransactionViewModel
    @State var showAddIncomeView = false
    @State var deleteIncome = false
    
    var body: some View {
        VStack(spacing: 15) {
            VStack {
                Text("Total Income")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("$\(viewModel.totalIncome, specifier: "%.2f")")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                if let highestSource = viewModel.highestIncomeCategory {
                    Text("Highest Source: \(highestSource)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.gradient))
            .padding(.horizontal)
            
            if viewModel.incomeBreakdown.isEmpty {
                Text("No income data available.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                IncomeBarChart(data: viewModel.incomeBreakdown)
                    .frame(height: 250)
                    .padding(.horizontal)
            }
            
            VStack {
                HStack {
                    Text("Recent Income")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: {
                        deleteIncome.toggle()
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
                    .sheet(isPresented: $deleteIncome) {
                        DeleteIncomeView(viewModel: viewModel)
                    }
                }
                .padding(.top)
                
                if !viewModel.transactions.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.transactions.filter { $0.type.rawValue == TransactionType.income.rawValue }.prefix(4), id: \.id) { entry in
                                IncomeCard(category: entry.category, amount: entry.amount)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                showAddIncomeView.toggle()
            }) {
                Text("Add Income")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .sheet(isPresented: $showAddIncomeView) {
                AddIncomeView(viewModel: viewModel)
            }
        }
        .navigationTitle("Income")
    }
}

struct IncomeCard: View {
    var category: String
    var amount: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(category)
                .font(.headline)
            Text("$\(amount, specifier: "%.2f")")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 130, height: 80)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
    }
}

struct DeleteIncomeView: View {
    @ObservedObject var viewModel: TransactionViewModel
    
    var body: some View {
        VStack {
            Text("Manage Your Income")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            List {
                ForEach(viewModel.transactions.filter { $0.type.rawValue == TransactionType.income.rawValue }, id: \.id) { entry in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(entry.category)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                        
                        Text("$\(entry.amount, specifier: "%.2f")") // Format the amount nicely
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
                    viewModel.deleteIncome(at: indexSet)
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}

struct AddIncomeView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var incomeAmount: String = ""
    @State private var incomeCategory: String = ""
    @State private var isRecurring: Bool = false
    @State private var recurrenceInterval: RecurrenceInterval = .monthly
    @Environment(\ .presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                TextField("Income Amount", text: $incomeAmount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                TextField("Income Category", text: $incomeCategory)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Toggle("Recurring Transaction", isOn: $isRecurring)
                    .padding()
                
                if isRecurring {
                    Picker("Recurrence Interval", selection: $recurrenceInterval) {
                        Text("Daily").tag(RecurrenceInterval.daily)
                        Text("Weekly").tag(RecurrenceInterval.weekly)
                        Text("Monthly").tag(RecurrenceInterval.monthly)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }
                
                Button(action: addIncome) {
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
            .navigationTitle("New Income")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    
    private func addIncome() {
        guard let amount = Double(incomeAmount), !incomeCategory.isEmpty else { return }
        let newTransaction = Transaction(
            id: UUID(),
            amount: amount,
            category: incomeCategory,
            date: Date(),
            type: TransactionType.income,
            isRecurring: isRecurring,
            recurrenceInterval: isRecurring ? recurrenceInterval : nil
        )
        viewModel.addIncome(transaction: newTransaction)
        presentationMode.wrappedValue.dismiss()
    }
}


struct IncomeBarChart: View {
    var data: [String: Double]
    
    var body: some View {
        Chart {
            ForEach(data.sorted(by: { $0.value > $1.value }), id: \.key) { category, amount in
                BarMark(
                    x: .value("Category", category),
                    y: .value("Amount", amount)
                )
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .cornerRadius(6)
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
                AxisTick()
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white).shadow(radius: 4))
    }
}


