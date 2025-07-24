import SwiftUI
internal import SwiftUIVisualEffects

// MARK: - Quick Action Button Component
struct QuickActionButton: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let borderColor: Color
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                QuickActionButtonIcon(
                    icon: icon,
                    iconColor: iconColor,
                    isEnabled: isEnabled
                )
                
                QuickActionButtonText(
                    title: title,
                    subtitle: subtitle,
                    isEnabled: isEnabled
                )
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(
                BlurEffect()
                    .blurEffectStyle(.systemUltraThinMaterialDark)
                    .opacity(isEnabled ? 1.0 : 0.5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isEnabled ? borderColor : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
    }
}
