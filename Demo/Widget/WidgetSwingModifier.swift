import SwiftUI
import ClockHandRotationKit

enum WidgetSwingDirection {
    case horizontal
    case vertical
}

struct WidgetSwingModifier: ViewModifier {
    let duration: CGFloat
    let direction: WidgetSwingDirection
    let distance: CGFloat

    private var alignment: Alignment {
        if direction == .vertical {
            return distance > 0 ? .top : .bottom
        }
        return distance > 0 ? .leading : .trailing
    }

    @ViewBuilder
    private func overlayView(content: Content) -> some View {
        let alignment = alignment
        GeometryReader { proxy in
            let size = proxy.size
            let extendLength = direction == .vertical ? size.height : size.width
            let length: CGFloat = abs(distance) + extendLength
            let innerDiameter = (length + extendLength) / 2
            let outerAlignment: Alignment = {
                if direction == .vertical {
                    return distance > 0 ? .bottom : .top
                }
                return distance > 0 ? .trailing : .leading
            }()

            ZStack(alignment: outerAlignment) {
                Color.clear
                ZStack(alignment: alignment) {
                    Color.clear
                    ZStack(alignment: alignment) {
                        Color.clear
                        content.clockHandRotationEffect(period: .custom(duration))
                    }
                    .frame(width: innerDiameter, height: innerDiameter)
                    .clockHandRotationEffect(period: .custom(-duration / 2))
                }
                .frame(width: length, height: length)
                .clockHandRotationEffect(period: .custom(duration))
            }
            .frame(width: size.width, height: size.height, alignment: alignment)
        }
    }

    func body(content: Content) -> some View {
        content.hidden()
            .overlay(overlayView(content: content))
    }
}

extension View {
    func widgetSwing(duration: CGFloat, direction: WidgetSwingDirection = .horizontal, distance: CGFloat) -> some View {
        modifier(WidgetSwingModifier(duration: duration, direction: direction, distance: distance))
    }
}
