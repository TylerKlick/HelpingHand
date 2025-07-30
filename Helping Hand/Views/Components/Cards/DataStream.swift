//
//  DataStream.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/13/25.
//

import SwiftUI
internal import SwiftUIVisualEffects

// MARK: - Data Stream Card
struct DataStreamCard: View {
    let data: [String]
    let onClear: () -> Void
    
    var body: some View {
        CardView {
            VStack(spacing: 12) {
                DataStreamHeader(
                    hasData: !data.isEmpty,
                    onClear: onClear
                )
                
                if data.isEmpty {
                    EmptyStateView(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "No Data Received",
                        subtitle: "Data from connected devices will appear here"
                    )
                } else {
                    DataStreamList(data: data)
                }
            }
        }
    }
}

// MARK: - Data Stream Header
struct DataStreamHeader: View {
    let hasData: Bool
    let onClear: () -> Void
    
    var body: some View {
        HStack {
            Text("Data Stream")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            if hasData {
                Button("Clear", action: onClear)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        BlurEffect()
                            .blurEffectStyle(.systemUltraThinMaterial)
                    )
                    .cornerRadius(4)
                    .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Data Stream List
struct DataStreamList: View {
    let data: [String]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 6) {
                ForEach(Array(data.enumerated().reversed()), id: \.offset) { _, dataItem in
                    DataStreamItem(data: dataItem)
                }
            }
            .padding(.horizontal, 2)
        }
        .frame(maxHeight: 150)
    }
}

// MARK: - Data Stream Item
struct DataStreamItem: View {
    let data: String
    
    var body: some View {
        HStack {
            Text(data)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("Now")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(
            BlurEffect()
                .blurEffectStyle(.systemUltraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        )
    }
}
