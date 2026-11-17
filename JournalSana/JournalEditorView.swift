//
//  JournalEditorView.swift
//  JournalSana
//

import SwiftUI
import SwiftData

// ─────────────────────────────────────────────
// شيت إضافة مذكرة جديدة أو تعديل مذكرة موجودة
// journal = nil  → مذكرة جديدة
// journal != nil → تعديل
// ─────────────────────────────────────────────
struct JournalEditorView: View {
    // @EnvironmentObject: نفس الـ ViewModel اللي أنشأناه في SplashView، يوصل هنا تلقائياً
    @EnvironmentObject var viewModel: JournalViewModel
    // dismiss: دالة من النظام تسكّر الشيت
    @Environment(\.dismiss) private var dismiss
    // context: الاتصال بالداتابيس (نحتاجه للإضافة)
    @Environment(\.modelContext) private var context

    // Optional (?) يعني ممكن تكون فيها مذكرة أو تكون nil
    let journal: Journal?

    // @State: متغيرات خاصة بهالشاشة، أي تغيير فيها يعيد رسم الواجهة
    @State private var title: String           // العنوان اللي يكتبه المستخدم
    @State private var content: String         // المحتوى اللي يكتبه المستخدم
    @State private var showDiscardAlert = false // هل نعرض تنبيه "Discard Changes"؟
    // @FocusState: يتحكم وين يكون المؤشر (الكيبورد)
    @FocusState private var isTitleFocused: Bool

    // init: يجهّز الشاشة
    // إذا فيه مذكرة نعبي الخانات بعنوانها ومحتواها، وإذا nil نخليها فاضية
    // (?? معناها: إذا القيمة nil استخدم اللي بعدها)
    init(journal: Journal?) {
        self.journal = journal
        _title = State(initialValue: journal?.title ?? "")
        _content = State(initialValue: journal?.content ?? "")
    }

    // هل المستخدم غيّر شي؟ نقارن النص الحالي بالأصلي
    // نستخدمها نقرر: نعرض تنبيه الإلغاء ولا نسكّر على طول
    private var hasChanges: Bool {
        title != (journal?.title ?? "") || content != (journal?.content ?? "")
    }

    // هل فيه شي يستاهل الحفظ؟ (العنوان أو المحتوى مو فاضي بعد حذف المسافات)
    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty ||
        !content.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // body: شكل الشاشة
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {

                // خانة العنوان (TextField = سطر واحد)
                TextField("", text: $title, prompt: Text("Title").foregroundColor(Color("TextSecondary")))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .focused($isTitleFocused)

                // التاريخ: تاريخ المذكرة إذا تعديل، أو تاريخ اليوم إذا جديدة
                Text((journal?.date ?? Date()).formatted(.dateTime.day(.twoDigits).month(.twoDigits).year()))
                    .font(.system(size: 14))
                    .foregroundColor(Color("TextSecondary"))

                // خانة المحتوى (TextEditor = عدة أسطر)
                // TextEditor ما فيه placeholder جاهز، فنحط Text فوقه بـ ZStack
                ZStack(alignment: .topLeading) {
                    // النص الرمادي يطلع بس إذا المحتوى فاضي
                    if content.isEmpty {
                        Text("Type your Journal...")
                            .font(.system(size: 20))
                            .foregroundColor(Color("TextSecondary"))
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false) // عشان الضغط يروح للـ TextEditor تحته
                    }

                    TextEditor(text: $content)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden) // نشيل الخلفية البيضاء الافتراضية
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color("SurfaceCard").ignoresSafeArea())
            .scrollDismissesKeyboard(.interactively) // السحب لتحت يخفي الكيبورد
            .toolbar {
                // زر X: إذا فيه تعديلات نسأل المستخدم، وإذا ما فيه نسكّر على طول
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
                    // تنبيه الإلغاء، يطلع من زر X نفسه
                    .confirmationDialog(
                        "Are you sure you want to discard changes on this journal?",
                        isPresented: $showDiscardAlert,
                        titleVisibility: .visible
                    ) {
                        // يسكّر الشيت بدون حفظ
                        Button("Discard Changes", role: .destructive) { dismiss() }
                        // يسكّر التنبيه بس ويكمل الكتابة
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
                    // Liquid Glass: زر زجاجي بارز بلون البنفسجي
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.circle)
                    .tint(Color("PrimaryAccent"))
                }
            }
            // أول ما تفتح الشاشة: إذا مذكرة جديدة نحط المؤشر على العنوان ويطلع الكيبورد
            .onAppear {
                if journal == nil { isTitleFocused = true }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDragIndicator(.visible) // الخط الصغير فوق الشيت
        // يمنع سحب الشيت لتحت إذا فيه تعديلات ما انحفظت
        .interactiveDismissDisabled(hasChanges)
    }

    // الحفظ: يقرر هل نضيف مذكرة جديدة أو نعدّل الموجودة، وبعدها يسكّر الشيت
    private func save() {
        // مذكرة جديدة فاضية ما نحفظها، بس نسكّر الشيت
        guard canSave else {
            dismiss()
            return
        }
        // if let: إذا journal فيها قيمة (مو nil) = تعديل، غير كذا = إضافة
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
