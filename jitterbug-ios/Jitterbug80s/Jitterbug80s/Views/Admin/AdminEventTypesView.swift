import SwiftUI

private let accentPink = Color(red: 0.93, green: 0.28, blue: 0.6)

struct AdminEventTypesView: View {
    @State private var types: [String] = []
    @State private var loading = true
    @State private var saving = false
    @State private var saveError: String?
    @State private var saveSuccess = false

    var body: some View {
        NavigationStack {
            Group {
                if loading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section {
                            Button {
                                addType()
                            } label: {
                                Label("Add event type", systemImage: "plus.circle.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .foregroundStyle(accentPink)
                        } header: {
                            Text("Event types")
                        } footer: {
                            Text("These options appear in the booking form. Edit names below, swipe left to delete, then tap Save.")
                        }

                        Section("Your event types") {
                            ForEach(types.indices, id: \.self) { i in
                                TextField("Type", text: $types[i])
                                    .textInputAutocapitalization(.words)
                            }
                            .onDelete(perform: delete)
                        }
                    }
                }
            }
            .navigationTitle("Event types")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") { save() }
                        .disabled(saving || loading)
                }
            }
            .task { load() }
            .alert("Saved", isPresented: $saveSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Event types saved. They will appear in the booking form on the app and website.")
            }
            .alert("Error", isPresented: Binding(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )) {
                Button("OK", role: .cancel) { saveError = nil }
            } message: {
                Text(saveError ?? "")
            }
        }
    }

    private func addType() {
        types.append("New type")
    }

    private func delete(at offsets: IndexSet) {
        types.remove(atOffsets: offsets)
    }

    private func load() {
        loading = true
        Task {
            types = await EventTypesService().getEventTypes()
            await MainActor.run { loading = false }
        }
    }

    private func save() {
        let valid = types
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        guard !valid.isEmpty else {
            saveError = "Keep at least one event type."
            return
        }
        saving = true
        saveError = nil
        Task {
            do {
                try await EventTypesService().saveEventTypes(valid)
                await MainActor.run {
                    types = valid
                    saving = false
                    saveSuccess = true
                }
            } catch {
                await MainActor.run {
                    saveError = error.localizedDescription
                    saving = false
                }
            }
        }
    }
}
