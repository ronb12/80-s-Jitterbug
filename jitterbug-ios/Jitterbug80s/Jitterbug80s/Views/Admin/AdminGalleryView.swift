import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

/// Owner gallery management still uses **Firestore**. The **customer** Gallery tab loads from **`GET {Public site URL}/api/data/gallery`** (Neon on Vercel) first. To keep them in sync, add photos via the **website admin** or point Firestore + API at the same data source.

private struct ImageDataTransfer: Transferable {
    let data: Data
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { ImageDataTransfer(data: $0) }
    }
}

struct AdminGalleryView: View {
    @State private var photos: [GalleryPhoto] = []
    @State private var loading = true
    @State private var newUrl = ""
    @State private var newCaption = ""
    @State private var uploadCaption = ""
    @State private var adding = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var uploadError: String?
    @State private var editingPhoto: GalleryPhoto?
    @State private var editCaption = ""

    var body: some View {
        NavigationStack {
            galleryMainContent
                .navigationTitle("Gallery")
                .task { load() }
                .onChange(of: selectedPhotoItem) { _, new in
                    guard let item = new else { return }
                    processPickedPhoto(item)
                }
                .sheet(item: $editingPhoto) { photo in
                    NavigationStack {
                        Form {
                            Section("Caption") {
                                #if os(iOS)
                                TextField("Caption", text: $editCaption, axis: .vertical)
                                    .lineLimit(2...4)
                                #else
                                TextField("Caption", text: $editCaption)
                                    .lineLimit(4)
                                #endif
                            }
                        }
                        #if os(macOS)
                        .controlSize(.small)
                        #endif
                        .jitterbugMacInsetLeadingScrollableForm()
                        .navigationTitle("Edit caption")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { editingPhoto = nil } }
                            ToolbarItem(placement: .confirmationAction) { Button("Save") { saveCaption(photo) } }
                        }
                    }
                    .jitterbugMacNavigationRootFill()
                    .jitterbugMacSheetChromeIfNeeded()
                }
        }
        .jitterbugMacNavigationRootFill()
    }

    @ViewBuilder
    private var galleryMainContent: some View {
        if loading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            galleryList
        }
    }

    private var galleryList: some View {
        List {
            Section("Upload from photo library") {
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label {
                        Text("Choose photo")
                    } icon: {
                        Image(systemName: "photo.on.rectangle.angular")
                            .symbolRenderingMode(.multicolor)
                    }
                }
                TextField("Caption (optional)", text: $uploadCaption)
                if let msg = uploadError {
                    Text(msg)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
            Section("Add photo by URL") {
                TextField("Image URL", text: $newUrl)
                    #if os(iOS)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    #endif
                TextField("Caption", text: $newCaption)
                Button("Add") { addPhoto() }
                    .disabled(newUrl.trimmingCharacters(in: .whitespaces).isEmpty || adding)
            }
            Section("Gallery") {
                ForEach(photos) { photo in
                    HStack {
                        AsyncImage(url: URL(string: photo.url)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().aspectRatio(contentMode: .fill)
                            case .failure:
                                Color.gray.opacity(0.3).overlay(
                                    Image(systemName: "photo")
                                        .symbolRenderingMode(.multicolor)
                                )
                            case .empty:
                                ProgressView()
                            @unknown default:
                                Color.gray.opacity(0.3)
                            }
                        }
                        .frame(width: 50, height: 50)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        Text(photo.caption.isEmpty ? "No caption" : photo.caption)
                            .lineLimit(1)
                        Spacer()
                        Button { editingPhoto = photo; editCaption = photo.caption } label: {
                            Image(systemName: "pencil")
                                .symbolRenderingMode(.multicolor)
                        }
                        Button(role: .destructive) { delete(photo) } label: {
                            Image(systemName: "trash")
                                .symbolRenderingMode(.multicolor)
                        }
                    }
                }
            }
        }
        .jitterbugMacListTightUnderNavigationTitle()
    }

    private func saveCaption(_ photo: GalleryPhoto) {
        Task {
            do {
                try await GalleryService().updatePhoto(id: photo.id, caption: editCaption)
                await MainActor.run {
                    if let i = photos.firstIndex(where: { $0.id == photo.id }) {
                        photos[i] = GalleryPhoto(id: photo.id, url: photo.url, caption: editCaption, order: photo.order, createdAt: photo.createdAt)
                    }
                    editingPhoto = nil
                }
            } catch {
                await MainActor.run { editingPhoto = nil }
            }
        }
    }

    private func processPickedPhoto(_ item: PhotosPickerItem) {
        uploadError = nil
        adding = true
        Task {
            do {
                guard let transfer = try await item.loadTransferable(type: ImageDataTransfer.self),
                      !transfer.data.isEmpty else {
                    await MainActor.run {
                        uploadError = "Could not load image."
                        adding = false
                        selectedPhotoItem = nil
                    }
                    return
                }
                let url = try await ImgurUploadService.uploadImage(transfer.data)
                let caption = uploadCaption.trimmingCharacters(in: .whitespaces)
                _ = try await GalleryService().addPhoto(url: url, caption: caption, order: photos.count)
                await MainActor.run {
                    uploadCaption = ""
                    selectedPhotoItem = nil
                    adding = false
                    uploadError = nil
                    load()
                }
            } catch {
                await MainActor.run {
                    uploadError = error.localizedDescription
                    adding = false
                    selectedPhotoItem = nil
                }
            }
        }
    }

    private func load() {
        loading = true
        Task {
            photos = await GalleryService().listPhotos()
            await MainActor.run { loading = false }
        }
    }

    private func addPhoto() {
        let url = newUrl.trimmingCharacters(in: .whitespaces)
        let caption = newCaption.trimmingCharacters(in: .whitespaces)
        guard !url.isEmpty else { return }
        adding = true
        Task {
            do {
                _ = try await GalleryService().addPhoto(url: url, caption: caption, order: photos.count)
                await MainActor.run {
                    newUrl = ""
                    newCaption = ""
                    adding = false
                    load()
                }
            } catch {
                await MainActor.run { adding = false }
            }
        }
    }

    private func delete(_ photo: GalleryPhoto) {
        Task {
            try? await GalleryService().deletePhoto(id: photo.id)
            await MainActor.run { load() }
        }
    }
}
