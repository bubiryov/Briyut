//
//  StatsView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 11.06.2023.
//

import SwiftUI
import SwiftUICharts

struct StatsView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDoctor: DBUser? = nil
    @State private var selectedDate: Date = Date()
    @State private var monthOrders: [OrderModel] = []
    @State private var sorted: [Double] = []
    @State private var lineChartData: ([Double], Date, Date)  = ([], Date(), Date())
    @State private var customPeriod: Bool = false
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    
    var body: some View {
        
        VStack {
            
            let calendar = Calendar.current
            let selectedMonth = calendar.component(.month, from: selectedDate)
            let currentMonth = calendar.component(.month, from: Date())
            
            BarTitle<BackButton, DoctorMenuPicker>(
                text: DateFormatter.customFormatter(format: "MMMM").getMonthNameInNominativeCase(from: selectedDate),
                leftButton: BackButton(), rightButton: DoctorMenuPicker(
                    vm: vm,
                    doctors: [.allDoctors] + vm.doctors.map(DoctorOption.user),
                    selectedDoctor: $selectedDoctor),
                action: { selectedDate = Date() }
            )
            ScrollView {
                if !customPeriod {
                    CustomDatePicker(
                        selectedDate: $selectedDate,
                        mode: .months,
                        pastTime: true
                    )
                }
                
                PieChartCard(
                    total: monthOrders.reduce(0.0) { $0 + Double($1.price) },
                    firstValue: monthOrders.filter { $0.isDone }.reduce(0.0) { $0 + Double($1.price) },
                    secondValue: monthOrders.filter { !$0.isDone }.reduce(0.0) { $0 + Double($1.price) },
                    selectedDate: selectedDate,
                    selectedMonth: selectedMonth,
                    currentMonth: currentMonth,
                    purpose: .earnings
                )
                
                PieChartCard(
                    total: nil,
                    firstValue: Double(monthOrders.filter { $0.isDone }.count),
                    secondValue: Double(monthOrders.filter { !$0.isDone }.count),
                    selectedDate: selectedDate,
                    selectedMonth: selectedMonth,
                    currentMonth: currentMonth,
                    purpose: .appointments
                )
                                
                LineChartCard(lineChartData: lineChartData)
                    .overlay {
                        if monthOrders.isEmpty {
                            Text("No data yet")
                                .font(Mariupol.medium, 17)
                                .foregroundColor(.secondary)
                        }
                    }
                
                VStack(spacing: 20) {
                    Toggle(isOn: $customPeriod.animation()) {
                        Text("Custom period")
                            .font(Mariupol.medium, 17)
                    }
                    .tint(.mainColor)
                    .padding(.trailing, 5)
                    
                    if customPeriod {
                        DatePicker("Start", selection: $startDate, displayedComponents: [.date])
                            .datePickerStyle(CompactDatePickerStyle())
                            .tint(.mainColor)
                            .onAppear {
                                startDate = lineChartData.1
                                endDate = lineChartData.2
                            }
                        
                        DatePicker("End", selection: $endDate, displayedComponents: [.date])
                            .datePickerStyle(CompactDatePickerStyle())
                            .tint(.mainColor)
                    }
                }
                .padding(.top)

                HStack { }
                .frame(height: 10)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.backgroundColor)
        .navigationBarBackButtonHidden()
        .onAppear {
            Task {
                monthOrders = try await vm.getDayMonthOrders(date: selectedDate, selectionMode: .month, doctorId: selectedDoctor?.userId)
                lineChartData = calculateModifiedCounts()
                print(lineChartData)
            }
        }
        .onChange(of: selectedDate) { newDate in
            Task {
                monthOrders = try await vm.getDayMonthOrders(date: newDate, selectionMode: .month, doctorId: selectedDoctor?.userId)
                lineChartData = calculateModifiedCounts()
            }
        }
        .onChange(of: selectedDoctor) { newDoctor in
            Task {
                monthOrders = try await vm.getDayMonthOrders(date: selectedDate, selectionMode: .month, doctorId: newDoctor?.userId)
                lineChartData = calculateModifiedCounts()
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
    }
    
    func calculateModifiedCounts() -> ([Double], Date, Date) {
        let dailyCounts = monthOrders.reduce(into: [Date: Int]()) { counts, order in
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: order.date.dateValue())
            let date = calendar.date(from: components)!
            counts[date, default: 0] += 1
        }
        
        let sortedDailyCounts = dailyCounts.sorted { $0.key < $1.key }
        let minDate = sortedDailyCounts.first?.key
        let maxDate = sortedDailyCounts.last?.key
        
        var modifiedCounts: [Double] = []
        
        if let minDate = minDate, let maxDate = maxDate {
            var currentDate = minDate
            
            while currentDate <= maxDate {
                let count = sortedDailyCounts.first { $0.key == currentDate }?.value ?? 0
                modifiedCounts.append(Double(count))
                
                currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
            }
        }
        
        return (modifiedCounts, minDate ?? Date(), maxDate ?? Date())
    }

}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StatsView()
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
    }
}

struct PieChartCard: View {
    
    let total: Double?
    let firstValue: Double
    let secondValue: Double
    let selectedDate: Date
    let selectedMonth: Int
    let currentMonth: Int
    let purpose: ChartCardPurpose
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(purpose.rawValue)
                        .font(Mariupol.bold, 22)
                    Text(selectedMonth == currentMonth ? "This month" : DateFormatter.customFormatter(format: "MMMM").getMonthNameInNominativeCase(from: selectedDate))
                        .font(Mariupol.bold, 20)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                if let total {
                    Text("\(purpose == .earnings ? "₴" : "") \(String(format: "%.0f", total))")
                        .lineLimit(1)
                        .font(.largeTitle)
                    
                }
            }
            
            HStack {
                
                if purpose == .appointments {
                    PieChart()
                        .data((firstValue == 0 && secondValue == 0) ? [1, 0] : [firstValue, secondValue])
                        .chartStyle(ChartStyle(
                            backgroundColor: .white,
                            foregroundColor: [
                                ColorGradient(.staticMainColor, .staticMainColor),
                                ColorGradient(.secondary, .secondary)
                            ]))
                        .frame(width: ScreenSize.height * 0.135, height: ScreenSize.height * 0.135)
                        .overlay {
                            Circle()
                                .frame(width: ScreenSize.height * 0.07)
                                .foregroundColor(.secondaryColor)
                                .overlay {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                }
                        }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: ScreenSize.width / 25, height: ScreenSize.width / 25)
                            .foregroundColor(.staticMainColor)
                        
                        VStack(alignment: .leading) {
                            Text("Done")
                                .font(Mariupol.bold, 17)
                                .foregroundColor(.secondary)
                            
                            Text("\(purpose == .earnings ? "₴ " : "")\(String(format: "%.0f", firstValue))")
                                .lineLimit(1)
                                .font(.title3.bold())
                        }
                        .padding(.leading, 10)
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .top) {
                        
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: ScreenSize.width / 25, height: ScreenSize.width / 25)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading) {
                            Text("Future")
                                .font(Mariupol.bold, 17)
                                .foregroundColor(.secondary)
                            
                            Text("\(purpose == .earnings ? "₴ " : "")\(String(format: "%.0f", secondValue))")
                                .lineLimit(1)
                                .font(.title3.bold())
                        }
                        .padding(.leading, 10)
//                        .padding(.trailing, 5)
                        
                    }
                }
                .padding(.vertical)
                
                if purpose == .earnings {
                    
                    Spacer()
                    
                    PieChart()
                        .data((firstValue == 0 && secondValue == 0) ? [1, 0] : [firstValue, secondValue])
                        .chartStyle(ChartStyle(
                            backgroundColor: .white,
                            foregroundColor: [
                                ColorGradient(.staticMainColor, .staticMainColor),
                                ColorGradient(.secondary, .secondary)
                            ]))
                        .frame(width: ScreenSize.height * 0.135, height: ScreenSize.height * 0.135)
                        .overlay {
                            Circle()
                                .frame(width: ScreenSize.height * 0.07)
                                .foregroundColor(.secondaryColor)
                                .overlay {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                }
                        }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .frame(minHeight: ScreenSize.height * 0.2)
        .background(Color.secondaryColor)
        .cornerRadius(ScreenSize.width / 20)
    }
}

struct LineChartCard: View {
    
    var lineChartData: ([Double], Date, Date)  = ([], Date(), Date())
    
    var body: some View {
        VStack {
            
            LineChart()
                .data(lineChartData.0)
                .chartStyle(ChartStyle(backgroundColor: .secondaryColor, foregroundColor: [ColorGradient(.staticMainColor, .staticMainColor)]))
            
            HStack {
                Text(DateFormatter.customFormatter(format: "dd.MM").string(from: lineChartData.1))
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                Spacer()
                Text(DateFormatter.customFormatter(format: "dd.MM").string(from: lineChartData.2))
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 20)
        .frame(height: ScreenSize.height * 0.23)
        .background(Color.secondaryColor)
        .cornerRadius(ScreenSize.width / 20)
    }
}
