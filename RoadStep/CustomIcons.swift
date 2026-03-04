import SwiftUI

// MARK: - Footprint Icon (Dashboard)
struct FootprintIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        // Sole
        p.addEllipse(in: CGRect(x: w * 0.2, y: h * 0.3, width: w * 0.6, height: h * 0.65))
        // Toes
        p.addEllipse(in: CGRect(x: w * 0.15, y: h * 0.08, width: w * 0.2, height: w * 0.2))
        p.addEllipse(in: CGRect(x: w * 0.4, y: h * 0.02, width: w * 0.2, height: w * 0.2))
        p.addEllipse(in: CGRect(x: w * 0.62, y: h * 0.1, width: w * 0.18, height: w * 0.18))
        return p
    }
}

// MARK: - Plus Circle Icon (Log Walk)
struct PlusCircleIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        let strokeW: CGFloat = r * 0.18
        // Outer circle
        p.addEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
        // Inner circle (cutout for ring effect)
        p.addEllipse(in: CGRect(x: center.x - r + strokeW, y: center.y - r + strokeW, width: (r - strokeW) * 2, height: (r - strokeW) * 2))
        // Horizontal bar of plus
        let t: CGFloat = r * 0.15
        let len: CGFloat = r * 0.45
        p.addRect(CGRect(x: center.x - len, y: center.y - t, width: len * 2, height: t * 2))
        // Vertical bar of plus
        p.addRect(CGRect(x: center.x - t, y: center.y - len, width: t * 2, height: len * 2))
        return p
    }
}

// MARK: - List Icon (History)
struct ListIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        for i in 0..<3 {
            let y = h * (0.2 + CGFloat(i) * 0.3)
            let barH = h * 0.12
            // Bullet
            p.addEllipse(in: CGRect(x: w * 0.05, y: y - barH / 2, width: barH, height: barH))
            // Line
            p.addRect(CGRect(x: w * 0.25, y: y - barH / 2, width: w * 0.65, height: barH))
        }
        return p
    }
}

// MARK: - Bar Chart Icon (Stats)
struct BarChartIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let barW = w * 0.2
        let gap = w * 0.05
        let heights: [CGFloat] = [0.5, 0.8, 0.35, 0.65]
        for (i, bh) in heights.enumerated() {
            let x = gap + CGFloat(i) * (barW + gap)
            let barH = h * bh
            p.addRoundedRect(in: CGRect(x: x, y: h - barH, width: barW, height: barH), cornerSize: CGSize(width: 2, height: 2))
        }
        return p
    }
}

// MARK: - Target Icon (Goals)
struct TargetIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        let lw: CGFloat = r * 0.12
        // Outer ring
        p.addPath(Circle().path(in: rect).strokedPath(StrokeStyle(lineWidth: lw)))
        // Middle ring
        let mr = r * 0.6
        p.addPath(Circle().path(in: CGRect(x: center.x - mr, y: center.y - mr, width: mr * 2, height: mr * 2)).strokedPath(StrokeStyle(lineWidth: lw)))
        // Center dot
        let cr = r * 0.2
        p.addEllipse(in: CGRect(x: center.x - cr, y: center.y - cr, width: cr * 2, height: cr * 2))
        return p
    }
}

// MARK: - Shape to Image helper
extension Shape {
    @MainActor
    func asImage(size: CGSize = CGSize(width: 28, height: 28), color: UIColor = .label) -> Image {
        let renderer = UIGraphicsImageRenderer(size: size)
        let uiImage = renderer.image { ctx in
            let path = self.path(in: CGRect(origin: .zero, size: size)).cgPath
            ctx.cgContext.addPath(path)
            ctx.cgContext.setFillColor(color.cgColor)
            ctx.cgContext.fillPath(using: .evenOdd)
        }
        return Image(uiImage: uiImage.withRenderingMode(.alwaysTemplate))
    }
}

// MARK: - Clock Icon (History)
struct ClockIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        let lw: CGFloat = r * 0.12
        // Circle
        p.addPath(Circle().path(in: rect).strokedPath(StrokeStyle(lineWidth: lw)))
        // Hour hand
        let handW = lw
        p.addRect(CGRect(x: center.x - handW / 2, y: center.y - r * 0.5, width: handW, height: r * 0.5))
        // Minute hand
        p.addRect(CGRect(x: center.x, y: center.y - handW / 2, width: r * 0.4, height: handW))
        return p
    }
}

// MARK: - Home Icon (Dashboard)
struct HomeIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        // Roof triangle
        p.move(to: CGPoint(x: w * 0.5, y: h * 0.05))
        p.addLine(to: CGPoint(x: w * 0.05, y: h * 0.45))
        p.addLine(to: CGPoint(x: w * 0.95, y: h * 0.45))
        p.closeSubpath()
        // House body
        p.addRect(CGRect(x: w * 0.15, y: h * 0.45, width: w * 0.7, height: h * 0.5))
        // Door
        p.addRect(CGRect(x: w * 0.38, y: h * 0.6, width: w * 0.24, height: h * 0.35))
        return p
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }

    static let brandGold = Color(hex: "D4A017")
    static let brandWhite = Color.white
    static let brandLightGray = Color(hex: "E8E8E8")
    static let brandDarkGray = Color(hex: "4A4A4A")
}
