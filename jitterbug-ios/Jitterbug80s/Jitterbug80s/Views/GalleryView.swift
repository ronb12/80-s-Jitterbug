import SwiftUI

private let accentPink = Color(red: 0.93, green: 0.28, blue: 0.6)

struct GalleryView: View {
    var onBook: (() -> Void)?
    @State private var photos: [GalleryPhoto] = []
    @State private var loading = true

    var body: some View {
        NavigationStack {
            Group {
                if loading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if photos.isEmpty {
                    emptyState
                } else {
                    photoGrid
                }
            }
            .navigationTitle("Gallery")
            .task {
                photos = await GalleryService().listPhotos()
                loading = false
            }
        }
    }

    private var emptyState: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("📸")
                    .font(.system(size: 56))
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
                            Color.gray.opacity(0.3)
                                .overlay(Image(systemName: "photo"))
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
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
}
