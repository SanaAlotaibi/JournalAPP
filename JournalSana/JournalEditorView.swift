//
//  JournalEditorView.swift
//  JournalSana
//

import SwiftUI
import SwiftData

// شيت إضافة مذكرة جديدة أو تعديل مذكرة موجودة
// journal = nil  → مذكرة جديدة
// journal != nil → تعديل
struct JournalEditorView: View {
    @EnvironmentObject var viewModel: JournalViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let journal: Journal?

    @State private var title: String
    @State private var content: String
    @State private var showDiscardAlert = false
    @FocusState private var isTitleFocused: Bool

    init(journal: Journal?) {
        self.journal = journal
        _title = State(initialValue: journal?.title ?? "")
        _content = State(initialValue: journal?.content ?? "")
    }

    // هل المستخدم غيّر شي؟
    private var hasChanges: Bool {
        title != (journal?.title ?? "") || content != (journal?.content ?? "")
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty ||
        !content.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                TextField("", text: $title, prompt: Text("Title").foregroundColor(Color("TextSecondary")))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .focused($isTitleFocused)

                Text((journal?.date ?? Date()).formatted(.dateTime.day(.twoDigits).month(.twoDigits).year()))
                    .font(.system(size: 14))
                    .foregroundColor(Color("TextSecondary"))

                ZStack(alignment: .topLeading) {
                    // placeholder للـ TextEditor
                    if content.isEmpty {
                        Text("Type your Journal...")
                            .font(.system(size: 20))
                            .foregroundColor(Color("TextSecondary"))
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $content)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color("SurfaceCard").ignoresSafeArea())
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                // زر X
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if hasChanges {
                            showDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .confirmationDialog(
                        "Are you sure you want to discard changes on this journal?",
                        isPresented: $showDiscardAlert,
                        titleVisibility: .visible
                    ) {
                        Button("Discard Changes", role: .destructive) { dismiss() }
                        // بدون role: .cancel لأن الـ popover يخفي زر الإلغاء
                        Button("Keep Editing") {}
                    }
                }

                // زر الحفظ ✓
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        save()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.circle)
                    .tint(Color("PrimaryAccent"))
                }
            }
            .onAppear {
                if journal == nil { isTitleFocused = true }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDragIndicator(.visible)
        // يمنع سحب الشيت لتحت إذا فيه تعديلات ما انحفظت
        .interactiveDismissDisabled(hasChanges)
    }

    private func save() {
        // مذكرة جديدة فاضية ما نحفظها، بس نسكّر الشيت
        guard canSave else {
            dismiss()
            return
        }
        if let journal {
            viewModel.updateJournal(journal, title: title, content: content)
        } else {
            viewModel.addJournal(title: title, content: content, context: context)
        }
        dismiss()
    }
}

#Preview {
    JournalEditorView(journal: nil)
        .environmentObject(JournalViewModel())
        .modelContainer(for: Journal.self, inMemory: true)
}
