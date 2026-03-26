import SwiftUI

private let landingPink = Color(red: 0.93, green: 0.28, blue: 0.6)
private let landingCyan = Color(red: 0.2, green: 0.85, blue: 0.95)

struct LandingView: View {
    var onEnter: () -> Void
    @State private var diamondScale: CGFloat = 0.9
    @State private var diamondOpacity: Double = 0.6
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.92
    @State private var ownerFirstName: String?

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            // Soft pink glow behind title area
            RadialGradient(
                colors: [
                    landingPink.opacity(0.14),
                    landingPink.opacity(0.05),
                    Color.clear
                ],
                center: .center,
                startRadius: 40,
                endRadius: 240
            )
            .ignoresSafeArea()
            // Subtle cyan accent (80s duo)
            RadialGradient(
                colors: [
                    Color.clear,
                    landingCyan.opacity(0.06),
                    Color.clear
                ],
                center: UnitPoint(x: 0.8, y: 0.3),
                startRadius: 20,
                endRadius: 180
            )
            .ignoresSafeArea()
            retroGridOverlay
            vignetteOverlay

            Group {
                #if os(macOS)
                ScrollView(.vertical, showsIndicators: true) {
                    landingMainStack
                        .padding(.top, 28)
                        .padding(.bottom, 40)
                        .frame(maxWidth: .infinity)
                }
                .jitterbugMacNavigationRootFill()
                .jitterbugMacFlushScrollContentMargins()
                #else
                landingMainStack
                #endif
            }
        }
        .task {
            let s = await SettingsService().getSiteSettings()
            ownerFirstName = firstName(from: s.ownerName)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { titleOpacity = 1 }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) { subtitleOpacity = 1 }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.4)) {
                buttonOpacity = 1
                buttonScale = 1
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                diamondScale = 1.15
                diamondOpacity = 1
            }
        }
    }

    /// Shared landing content; macOS wraps this in `ScrollView` so short windows can still reach **Enter**.
    @ViewBuilder
    private var landingMainStack: some View {
        VStack(spacing: 36) {
            #if os(macOS)
            Spacer(minLength: 24)
            #else
            Spacer()
            #endif
            VStack(spacing: 8) {
                if let first = ownerFirstName, !first.isEmpty {
                    Text("\(first)'s")
                        .font(.custom("SnellRoundhand-Bold", size: 26))
                        .foregroundStyle(.white.opacity(0.9))
                        .opacity(titleOpacity)
                }
                diamondTitle
            }
            VStack(spacing: 16) {
                Text("Retro Photo Booth")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white.opacity(0.95), .white.opacity(0.75)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(subtitleOpacity)
                neonLine
                decorativeDiamondLine
            }
            #if os(macOS)
            Spacer(minLength: 24)
            #else
            Spacer()
            #endif
            VStack(spacing: 14) {
                Button(action: onEnter) {
                    Text("Enter")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [landingPink, landingPink.opacity(0.88)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .shadow(color: landingPink.opacity(0.6), radius: 14, x: 0, y: 4)
                        .overlay(
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.4), Color.white.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                                .padding(1)
                        )
                }
                .scaleEffect(buttonScale)
                .opacity(buttonOpacity)
                Text("Serving Augusta, GA & surrounding areas")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 48)
            .padding(.bottom, 52)
        }
    }

    private func firstName(from fullName: String) -> String {
        let t = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let first = t.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true).first.map(String.init)
        return first ?? t
    }

    private var neonLine: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        landingPink.opacity(0.5),
                        landingCyan.opacity(0.35),
                        landingPink.opacity(0.5),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 2)
            .frame(maxWidth: 140)
            .opacity(subtitleOpacity)
    }

    private var retroGridOverlay: some View {
        GeometryReader { geo in
            Path { path in
                let step: CGFloat = 56
                for x in stride(from: 0, through: geo.size.width + step, by: step) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geo.size.height))
                }
                for y in stride(from: 0, through: geo.size.height + step, by: step) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
            }
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.09),
                        landingPink.opacity(0.05),
                        landingCyan.opacity(0.03),
                        Color.white.opacity(0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
        }
        .ignoresSafeArea()
    }

    private var vignetteOverlay: some View {
        GeometryReader { geo in
            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.4)],
                center: .center,
                startRadius: geo.size.width * 0.3,
                endRadius: geo.size.width * 0.85
            )
        }
        .ignoresSafeArea()
    }

    private var decorativeDiamondLine: some View {
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { i in
                if i % 2 == 0 {
                    DiamondShape()
                        .fill(landingPink.opacity(0.6))
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(landingPink.opacity(0.4))
                        .frame(width: 3, height: 3)
                }
            }
        }
    }

    private var diamondTitle: some View {
        HStack(spacing: 14) {
            diamondGroup
            VStack(spacing: 2) {
                Text("80's")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [landingPink, landingPink.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: landingPink.opacity(0.6), radius: 10, x: 0, y: 0)
                Text("Jitterbug")
                    .font(.system(size: 38, weight: .heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [landingPink, landingPink.opacity(0.88)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: landingPink.opacity(0.6), radius: 12, x: 0, y: 0)
            }
            .opacity(titleOpacity)
            diamondGroup
        }
        .padding(.horizontal, 28)
    }

    private var diamondGroup: some View {
        VStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 8) {
                    diamondShape
                    diamondShape
                }
            }
        }
        .scaleEffect(diamondScale)
        .opacity(diamondOpacity)
    }

    private var diamondShape: some View {
        DiamondShape()
            .fill(landingPink.opacity(0.8))
            .frame(width: 14, height: 14)
    }
}

struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        path.move(to: CGPoint(x: midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}
