////
////  QuickAction.swift
////  Helping Hand
////
////  Created by Tyler Klick on 7/14/25.
////
//
//import SwiftUI
//internal import SwiftUIVisualEffects
//
//struct QuickActionButton: View {
//    let quickAction: QuickAction
//    let showProgressIndicator: Bool
//    
//    init(_ quickAction: QuickAction, showProgressIndicator: Bool = false) {
//        self.quickAction = quickAction
//        self.showProgressIndicator = showProgressIndicator
//    }
//    
//    var body: some View {
//        Button(action: quickAction.action) {
//            HStack(spacing: 8) {
//                QuickActionIcon(
//                    icon: quickAction.icon,
//                    color: quickAction.color,
//                    isActive: quickAction.isActive,
//                    showProgressIndicator: showProgressIndicator
//                )
//                
//                QuickActionText(
//                    title: quickAction.title,
//                    subtitle: quickAction.subtitle
//                )
//                
//                Spacer()
//            }
//            .padding(12)
//            .background(
//                BlurEffect()
//                    .blurEffectStyle(blurStyle)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(quickAction.color, lineWidth: 1)
//                    )
//            )
//        }
//        .buttonStyle(PlainButtonStyle())
//        .disabled(!quickAction.isEnabled)
//        .opacity(quickAction.isEnabled ? 1.0 : 0.6)
//    }
//    
//    private var blurStyle: UIBlurEffect.Style {
//        if quickAction.isActive {
//            return .systemUltraThinMaterialLight
//        } else {
//            return .systemUltraThinMaterialDark
//        }
//    }
//}
//
//// MARK: - Quick Action Icon
//struct QuickActionIcon: View {
//    let icon: String
//    let color: Color
//    let isActive: Bool
//    let showProgressIndicator: Bool
//    
//    var body: some View {
//        Group {
//            if showProgressIndicator && isActive {
//                ProgressView()
//                    .scaleEffect(0.8)
//                    .frame(width: 16, height: 16)
//            } else {
//                Image(systemName: icon)
//                    .font(.title3)
//                    .foregroundColor(color)
//            }
//        }
//    }
//}
//
//// MARK: - Quick Action Text
//struct QuickActionText: View {
//    let title: String
//    let subtitle: String
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 2) {
//            Text(title)
//                .font(.caption)
//                .fontWeight(.medium)
//            
//            Text(subtitle)
//                .font(.caption2)
//                .foregroundColor(.secondary)
//        }
//    }
//}
