//
//  SettingsView.swift
//  Nestory
//
//  Created by Assistant on 8/9/25.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("sortBy") private var sortBy = "name"
    @AppStorage("showGridView") private var showGridView = false
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("useSystemTheme") private var useSystemTheme = true
    @State private var showingExportSheet = false
    @State private var showingAbout = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    HStack {
                        Label("Use System Theme", systemImage: "iphone")
                        Spacer()
                        Toggle("", isOn: $useSystemTheme)
                    }

                    if !useSystemTheme {
                        HStack {
                            Label("Dark Mode", systemImage: "moon.fill")
                            Spacer()
                            Toggle("", isOn: $darkModeEnabled)
                        }
                    }
                }

                Section("General") {
                    HStack {
                        Label("Notifications", systemImage: "bell")
                        Spacer()
                        Toggle("", isOn: $enableNotifications)
                    }

                    HStack {
                        Label("Default View", systemImage: "square.grid.2x2")
                        Spacer()
                        Picker("", selection: $showGridView) {
                            Text("List").tag(false)
                            Text("Grid").tag(true)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }

                    HStack {
                        Label("Sort By", systemImage: "arrow.up.arrow.down")
                        Spacer()
                        Picker("", selection: $sortBy) {
                            Text("Name").tag("name")
                            Text("Date").tag("date")
                            Text("Category").tag("category")
                        }
                        .pickerStyle(.menu)
                    }
                }

                Section("Data Management") {
                    Button(action: { showingExportSheet = true }) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }

                    Button(action: {}) {
                        Label("Backup to iCloud", systemImage: "icloud.and.arrow.up")
                    }

                    Button(action: {}) {
                        Label("Restore from Backup", systemImage: "icloud.and.arrow.down")
                    }
                }

                Section("Storage") {
                    HStack {
                        Label("Storage Used", systemImage: "internaldrive")
                        Spacer()
                        Text("24.5 MB")
                            .foregroundColor(.secondary)
                    }

                    Button(action: {}) {
                        Label("Clear Cache", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }

                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    Button(action: { showingAbout = true }) {
                        Label("About Nestory", systemImage: "questionmark.circle")
                    }

                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }

                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingExportSheet) {
                ExportView()
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
}

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)

                Text("Export Your Inventory")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Choose a format to export your inventory data")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)

                VStack(spacing: 12) {
                    ExportButton(title: "CSV File", icon: "doc.text", action: {})
                    ExportButton(title: "PDF Report", icon: "doc.richtext", action: {})
                    ExportButton(title: "JSON Data", icon: "doc.badge.gearshape", action: {})
                }
                .padding(.top)

                Spacer()
            }
            .padding()
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ExportButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .foregroundColor(.primary)
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)

                Text("Nestory")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Version 1.0.0")
                    .foregroundColor(.secondary)

                Text("Your personal home inventory manager")
                    .multilineTextAlignment(.center)
                    .padding()

                VStack(alignment: .leading, spacing: 12) {
                    Label("Track your belongings", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Label("Organize by location", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Label("Search and filter", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Label("Export your data", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                Spacer()

                Text("© 2025 Nestory")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
