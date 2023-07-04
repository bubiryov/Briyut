//
//  PieChartCard.swift
//  Briyut
//
//  Created by Egor Bubiryov on 04.07.2023.
//

import SwiftUI
import SwiftUICharts

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
            
            pieChartCartHeader
            
            HStack {
                
                if purpose == .appointments {

                    pieChart
                    
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        colorRectangle(color: .staticMainColor)
                        
                        detailAmount(
                            title: "done-orders-string",
                            value: firstValue
                        )
                        
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .top) {
                        
                        colorRectangle(color: .secondary)
                        
                        detailAmount(
                            title: "future-orders-string",
                            value: secondValue
                        )
                        
                    }
                }
                .padding(.vertical)
                
                if purpose == .earnings {
                    
                    Spacer()
                    
                    pieChart
                    
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

struct PieChartCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            PieChartCard(
                total: 15000,
                firstValue: 9000,
                secondValue: 6000,
                selectedDate: Date(),
                selectedMonth: 1,
                currentMonth: 1,
            purpose: .earnings)
        }
        .padding(.horizontal, 20)
    }
}

extension PieChartCard {
    
    var pieChartCartHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(purpose.rawValue.localized)
                    .font(Mariupol.bold, 22)
                Text(selectedMonth == currentMonth ? "this-month-string".localized : DateFormatter.customFormatter(format: "MMMM").getMonthNameInNominativeCase(from: selectedDate))
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
    }
    
    var pieChart: some View {
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
    
    func colorRectangle(color: Color) -> some View {
        return RoundedRectangle(cornerRadius: 4)
            .frame(width: UIScreen.main.bounds.width / 25, height: UIScreen.main.bounds.width / 25)
            .foregroundColor(color)
    }
    
    func detailAmount(title: String, value: Double) -> some View {
        return VStack(alignment: .leading) {
            Text(title.localized)
                .font(Mariupol.bold, 17)
                .foregroundColor(.secondary)
            
            Text("\(purpose == .earnings ? "₴ " : "")\(String(format: "%.0f", value))")
                .lineLimit(1)
                .font(.title3.bold())
        }
        .padding(.leading, 10)
    }     
}
