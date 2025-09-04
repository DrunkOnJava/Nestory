//
// Layer: Features
// Module: Settings/Components
// Purpose: Support and help functionality component for Settings
//

import SwiftUI
import Foundation

struct SupportComponent: View {
    var body: some View {
        Section("Support & Help") {
            NavigationLink(destination: HelpView()) {
                Label("Help Center", systemImage: "questionmark.circle")
            }
            
            NavigationLink(destination: FAQView()) {
                Label("Frequently Asked Questions", systemImage: "doc.text")
            }
            
            Button(action: contactSupport) {
                Label("Contact Support", systemImage: "envelope")
            }
            
            NavigationLink(destination: FeatureRequestView()) {
                Label("Request a Feature", systemImage: "lightbulb")
            }
        }
    }
    
    private func contactSupport() {
        let email = "support@nestoryapp.com"
        let subject = "Nestory Support Request"
        let body = "Please describe your issue or question:"
        
        let urlString = "mailto:\(email)?subject=\(subject)&body=\(body)"
        if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            UIApplication.shared.open(url)
        }
    }
}

private struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Getting Started")
                    .font(.headline)
                
                Text("Welcome to Nestory! Here are some tips to get you started:")
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Add items by tapping the + button")
                    Text("• Take photos to document your belongings")
                    Text("• Organize items by room and category")
                    Text("• Track warranties and receipts")
                    Text("• Generate insurance reports when needed")
                }
                
                Text("Advanced Features")
                    .font(.headline)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Use search filters to find items quickly")
                    Text("• Export your data for backup")
                    Text("• Set up warranty expiration notifications")
                    Text("• Scan receipts with OCR technology")
                }
            }
            .padding()
        }
        .navigationTitle("Help")
    }
}

private struct FAQView: View {
    var body: some View {
        List {
            FAQItem(
                question: "How do I backup my data?",
                answer: "Your data is automatically synced to iCloud. You can also export your data from Settings > Export Data."
            )
            
            FAQItem(
                question: "Can I add custom categories?",
                answer: "Yes! When adding or editing an item, you can create new categories or select from existing ones."
            )
            
            FAQItem(
                question: "How do warranty notifications work?",
                answer: "Enable notifications in Settings, and Nestory will alert you before your warranties expire."
            )
            
            FAQItem(
                question: "Is my data secure?",
                answer: "Yes! All data is encrypted and stored securely on your device and in iCloud."
            )
        }
        .navigationTitle("FAQ")
    }
}

private struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(question)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(answer)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .transition(.opacity)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct FeatureRequestView: View {
    @State private var featureDescription = ""
    @State private var showingSuccessAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What feature would you like to see in Nestory?")
                .font(.headline)
            
            TextEditor(text: $featureDescription)
                .border(Color.gray.opacity(0.3))
                .frame(minHeight: 100)
            
            Button("Submit Feature Request") {
                submitFeatureRequest()
            }
            .disabled(featureDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Feature Request")
        .alert("Thank you!", isPresented: $showingSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("Your feature request has been submitted. We appreciate your feedback!")
        }
    }
    
    private func submitFeatureRequest() {
        // In a real app, this would send the request to your backend
        showingSuccessAlert = true
        featureDescription = ""
    }
}

#Preview {
    NavigationView {
        List {
            SupportComponent()
        }
        .navigationTitle("Settings")
    }
}