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
            
            TopBar<BackButton, DoctorMenuPicker>(
                text: DateFormatter.customFormatter(format: "MMMM").getMonthNameInNominativeCase(from: selectedDate),
                leftButton: BackButton(), rightButton: DoctorMenuPicker(
                    vm: vm,
                    doctors: [.allDoctors] + vm.doctors.map(DoctorOption.user),
                    selectedDoctor: $selectedDoctor),
                action: { selectedDate = Date() }
            )
            
            ScrollView {
                if !customPeriod {
                    BarDatePicker(
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
                        if lineChartData.0.count < 2 || lineChartData.0.allSatisfy({ $0 == 0 }){
                            Text("no-data-yet-string")
                                .font(Mariupol.medium, 17)
                                .foregroundColor(.secondary)
                        }
                    }
                
                customPeriodSettings
                

                HStack { }
                .frame(height: 10)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.backgroundColor)
        .navigationBarBackButtonHidden()
        .onAppear {
            fetchDataAndUpdate(date: selectedDate, doctor: selectedDoctor, startDate: nil, endDate: nil, selectionMode: .month)
        }
        .onChange(of: selectedDate) { newDate in
            fetchDataAndUpdate(date: newDate, doctor: selectedDoctor, startDate: startDate, endDate: endDate, selectionMode: .month)
        }
        .onChange(of: selectedDoctor) { newDoctor in
            fetchDataAndUpdate(date: selectedDate, doctor: newDoctor, startDate: startDate, endDate: endDate, selectionMode: customPeriod ? .custom : .month)
        }
        .onChange(of: startDate) { newStartDate in
            if customPeriod {
                fetchDataAndUpdate(date: Date(), doctor: selectedDoctor, startDate: newStartDate, endDate: endDate, selectionMode: .custom)
            }
        }
        .onChange(of: endDate) { newSecondDate in
            if customPeriod {
                fetchDataAndUpdate(date: Date(), doctor: selectedDoctor, startDate: startDate, endDate: newSecondDate, selectionMode: .custom)
            }
        }
        .onChange(of: customPeriod) { newValue in
            if newValue {
                startDate = lineChartData.1
                endDate = lineChartData.2
            } else {
                fetchDataAndUpdate(date: selectedDate, doctor: selectedDoctor, startDate: nil, endDate: nil, selectionMode: .month)
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

// MARK: Components

extension StatsView {
    var customPeriodSettings: some View {
        VStack(spacing: 20) {
            Toggle(isOn: $customPeriod.animation()) {
                Text("custom-period-string")
                    .font(Mariupol.medium, 17)
            }
            .tint(.mainColor)
            .padding(.trailing, 5)
            
            if customPeriod {
                DatePicker("start-string", selection: $startDate, displayedComponents: [.date])
                    .datePickerStyle(CompactDatePickerStyle())
                    .tint(.mainColor)
                
                DatePicker("end-string", selection: $endDate, displayedComponents: [.date])
                    .datePickerStyle(CompactDatePickerStyle())
                    .tint(.mainColor)
            }
        }
        .padding(.top)

    }
}

// MARK: Functions

extension StatsView {
    
    func calculateModifiedCounts(selectionMode: DateSelectionMode) -> ([Double], Date, Date) {
        let dailyCounts = monthOrders.reduce(into: [Date: Int]()) { counts, order in
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: order.date.dateValue())
            let date = calendar.date(from: components)!
            counts[date, default: 0] += 1
        }
        
        let sortedDailyCounts = dailyCounts.sorted { $0.key < $1.key }
        let minDate: Date? = {
            if selectionMode == .month {
                return sortedDailyCounts.first?.key
            } else {
                return startDate
            }
        }()
        
        
        let maxDate: Date? = {
            if selectionMode == .month {
                return sortedDailyCounts.last?.key
            } else {
                return endDate
            }
        }()
        
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
    
    func fetchDataAndUpdate(
        date: Date,
        doctor: DBUser?,
        startDate: Date?,
        endDate: Date?,
        selectionMode: DateSelectionMode) {
        Task {
            do {
                monthOrders = try await vm.getDayMonthOrders(date: date, selectionMode: selectionMode, doctorId: doctor?.userId, firstDate: startDate, secondDate: endDate)
                lineChartData = calculateModifiedCounts(selectionMode: selectionMode)
            } catch {
                print("Can't get or update data")
            }
        }
    }

}
