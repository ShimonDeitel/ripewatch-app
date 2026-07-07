import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: Plant?

    @State private var draftPlantname: String = ""
    @State private var draftVariety: String = ""
    @State private var draftRipenwindow: String = ""
    @State private var draftNotes: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.items) { item in
                            PlantRow(item: item)
                                .listRowBackground(Theme.card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingItem = item
                                    loadDraft(from: item)
                                    showingAdd = true
                                }
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Ripewatch")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            editingItem = nil
                            clearDraft()
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                addEditSheet
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .tint(Theme.accent)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(Theme.textSecondary)
            Text("No plants yet")
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)
            Text("Tap + to add your first entry.")
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var addEditSheet: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Plant name", text: $draftPlantname)
                        .accessibilityIdentifier("field_plantName")
                        .keyboardType(default)
                    TextField("Variety", text: $draftVariety)
                        .accessibilityIdentifier("field_variety")
                        .keyboardType(default)
                    TextField("Ripen window", text: $draftRipenwindow)
                        .accessibilityIdentifier("field_ripenWindow")
                        .keyboardType(default)
                    TextField("Notes", text: $draftNotes)
                        .accessibilityIdentifier("field_notes")
                        .keyboardType(default)
                }
            }
            .navigationTitle(editingItem == nil ? "Add Plant" : "Edit Plant")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingAdd = false }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }

    private func loadDraft(from item: Plant) {
        draftPlantname = item.plantName
        draftVariety = item.variety
        draftRipenwindow = item.ripenWindow
        draftNotes = item.notes
    }

    private func clearDraft() {
        draftPlantname = ""
        draftVariety = ""
        draftRipenwindow = ""
        draftNotes = ""
    }

    private func save() {
        if let editing = editingItem {
            var updated = editing
            updated.plantName = draftPlantname
            updated.variety = draftVariety
            updated.ripenWindow = draftRipenwindow
            updated.notes = draftNotes
            store.update(updated)
        } else {
            let item = Plant(plantName: draftPlantname, variety: draftVariety, ripenWindow: draftRipenwindow, notes: draftNotes)
            store.add(item)
        }
        showingAdd = false
    }
}

struct PlantRow: View {
    let item: Plant

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.plantName.isEmpty ? "Untitled" : item.plantName)
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)
            Text(item.createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
