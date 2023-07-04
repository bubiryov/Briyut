//
//  LineChartCard.swift
//  Briyut
//
//  Created by Egor Bubiryov on 04.07.2023.
//

import SwiftUI
import SwiftUICharts

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

struct LineChartCard_Previews: PreviewProvider {
    static var previews: some View {
        LineChartCard()
    }
}
