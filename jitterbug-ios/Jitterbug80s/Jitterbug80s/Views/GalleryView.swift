import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

private let accentPink = Color(red: 0.93, green: 0.28, blue: 0.6)

struct GalleryView: View {
    var onBook: (() -> Void)?
    @State private var photos: [GalleryPhoto] = []
    @State private var loading = true

    private var placeholderGrayFill: Color {
        #if os(iOS)
        Color(uiColor: .systemGray5)
        #elseif os(macOS)
        Color(nsColor: .separatorColor)
        #else
        Color.gray.opacity(0.25)
        #endif
    }

    var body: some View {
        NavigationStack {
            Group {
                if loading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading gallery…")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if photos.isEmpty {
                    emptyState
                } else {
                    photoGrid
                }
            }
            .navigationTitle("Gallery")
            .task { await loadPhotos(showFullScreenSpinner: true) }
            .refreshable { await loadPhotos(showFullScreenSpinner: false) }
        }
    }

    private func loadPhotos(showFullScreenSpinner: Bool) async {
        if showFullScreenSpinner { loading = true }
        photos = await GalleryService().listPhotos()
        if showFullScreenSpinner { loading = false }
    }

    /// Bundled color icon (`IconGallery` in Assets — Twemoji framed picture 🖼).
    private var emptyGalleryIcon: some View {
        ZStack {
            Circle()
                .fill(Color.secondary.opacity(0.14))
                .frame(width: 120, height: 120)
            Image("IconGallery")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .accessibilityHidden(true)
        }
        .accessibilityHidden(true)
    }

    private var emptyState: some View {
        ScrollView {
            VStack(spacing: 24) {
                emptyGalleryIcon
                Text("From our events")
                    .font(.title2.weight(.bold))
                Text("Photos from our events will appear here. Book us for your next party and you could be in the gallery.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                if let onBook = onBook {
                    Button(action: onBook) {
                        Text("Request a booking")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(accentPink)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 8)
                }
            }
            .padding(32)
            .frame(maxWidth: .infinity)
        }
    }

    private var photoGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                ForEach(photos) { photo in
                    AsyncImage(url: URL(string: photo.url)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            imageLoadFailedPlaceholder
                        case .empty:
                            ProgressView()
                        @unknown default:
                            imageLoadFailedPlaceholder
                        }
                    }
                    .frame(height: 150)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(alignment: .bottom) {
                        if !photo.caption.isEmpty {
                            Text(photo.caption)
                                .font(.caption2)
                                .lineLimit(2)
                                .padding(6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.ultraThinMaterial)
                        }
                    }
                }
            }
            .padding()
        }
    }

    private var imageLoadFailedPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(placeholderGrayFill)
            VStack(spacing: 6) {
                Image("IconGallery")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .opacity(0.85)
                    .accessibilityHidden(true)
                Text("Couldn’t load")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
