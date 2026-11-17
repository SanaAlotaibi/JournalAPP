//
//  MainJournalView.swift
//  JournalSana
//
//  Created by Sana Alotaibi on 02/06/1448 AH.
//

import SwiftUI
import SwiftData

// ─────────────────────────────────────────────
// الصفحة الرئيسية (View)
// تعرض قائمة المذكرات، أو الواجهة الفارغة إذا ما فيه مذكرات
// وفيها: الفلتر، زر الإضافة، البحث، السحب للحذف
// ─────────────────────────────────────────────
struct MainJournalView: View {
    // الـ ViewModel المشترك (جاي من SplashView)
    @EnvironmentObject var viewModel: JournalViewModel
    // الاتصال بالداتابيس (نحتاجه للحذف)
    @Environment(\.modelContext) private var context
    // نجيب المذكرات من SwiftData، وتتحدث تلقائياً عند أي إضافة أو تعديل أو حذف
    @Query(sort: \Journal.date, order: .reverse) private var journals: [Journal]

    @State private var showNewJournalSheet = false    // هل نعرض شيت مذكرة جديدة؟
    @State private var selectedJournal: Journal?      // المذكرة اللي نعدّلها (nil = ما فيه)
    @State private var journalToDelete: Journal?      // المذكرة اللي بنحذفها (nil = ما فيه)

    // body: شكل الصفحة
    var body: some View {
        NavigationStack {
            ZStack {
                // الخلفية السوداء تغطي الشاشة كاملة
                Color("BackgroundPrimary").ignoresSafeArea()

                // نختار وش نعرض:
                if journals.isEmpty {
                    // 1) ما فيه مذكرات أبداً → الواجهة الفارغة
                    emptyStateView
                } else if viewModel.filteredJournals(from: journals).isEmpty {
                    // 2) فيه مذكرات بس البحث ما لقى شي → رسالة "No Results"
                    ContentUnavailableView.search(text: viewModel.searchText)
                } else {
                    // 3) فيه نتائج → القائمة
                    journalList
                }
            }
            .navigationTitle("Journal") // العنوان الكبير فوق
            .preferredColorScheme(.dark)
            .toolbar {
                // الزرين فوق على اليمين (النظام يحطهم في كبسولة Liquid Glass وحدة)
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // زر الفلتر: يفتح قائمة فيها خيارين للترتيب
                    Menu {
                        Button("Sort by Bookmark") {
                            viewModel.sortOption = .bookmark
                        }
                        Button("Sort by Entry Date") {
                            viewModel.sortOption = .entryDate
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .foregroundColor(.white)
                    }

                    // زر الإضافة: يفتح شيت مذكرة جديدة
                    Button {
                        showNewJournalSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
            }
            // خانة البحث (تطلع تحت)، النص يتخزن في viewModel.searchText
            .searchable(text: $viewModel.searchText, prompt: "Search")
            // شيت مذكرة جديدة: يطلع لما showNewJournalSheet = true
            .sheet(isPresented: $showNewJournalSheet) {
                JournalEditorView(journal: nil)
                    .environmentObject(viewModel)
            }
            // شيت تعديل مذكرة: يطلع لما selectedJournal يصير فيه مذكرة
            .sheet(item: $selectedJournal) { journal in
                JournalEditorView(journal: journal)
                    .environmentObject(viewModel)
            }
            // تنبيه الحذف: يطلع لما journalToDelete يصير فيه مذكرة
            // الـ Binding يحوّل (فيه مذكرة أو nil) إلى (true أو false)
            .alert("Delete Journal?", isPresented: Binding(
                get: { journalToDelete != nil },
                set: { if !$0 { journalToDelete = nil } }
            )) {
                // إلغاء: ما نحذف شي
                Button("Cancel", role: .cancel) {
                    journalToDelete = nil
                }
                // حذف: نحذف المذكرة من الداتابيس مع أنيميشن
                Button("Delete", role: .destructive) {
                    if let journal = journalToDelete {
                        withAnimation { viewModel.deleteJournal(journal, context: context) }
                    }
                    journalToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this journal?")
            }
        }
    }

    // قائمة المذكرات: كرت لكل مذكرة، بعد البحث والترتيب
    private var journalList: some View {
        List {
            ForEach(viewModel.filteredJournals(from: journals)) { journal in
                // الكرت، ولما ينضغط البوكمارك نقلب حالته
                JournalCardView(journal: journal) {
                    viewModel.toggleBookmark(for: journal)
                }
                .contentShape(Rectangle())
                // الضغط على الكرت يفتح شيت التعديل
                .onTapGesture {
                    selectedJournal = journal
                }
                // السحب لليسار يطلع زر الحذف الأحمر، والضغط عليه يطلع التنبيه
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        journalToDelete = journal
                    } label: {
                        Image(systemName: "trash.fill")
                    }
                    .tint(Color("Destructive"))
                }
                // شكل الصف: مسافات حول الكرت، بدون خط فاصل، بدون خلفية
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    // الواجهة الفارغة (Empty State): تطلع لما ما يكون فيه ولا مذكرة
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            // صورة الكتاب المفتوح من الـ Assets
            Image("33")
                .resizable()
                .scaledToFit()
                .frame(width: 130, height: 130)
                .accessibilityHidden(true) // صورة تزيين، VoiceOver ما يقراها

            Text("Begin Your Journal")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("TextAccent"))

            Text("Craft your personal diary, tap the\nplus icon to begin")
                .font(.system(size: 18, weight: .light))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .padding()
    }
}

// Preview بدون مذكرات (الواجهة الفارغة)
#Preview {
    MainJournalView()
        .environmentObject(JournalViewModel())
        .modelContainer(for: Journal.self, inMemory: true)
}

// Preview فيه 3 مذكرات تجريبية (داتابيس مؤقتة تنمسح)
#Preview("With Journals") {
    let container = try! ModelContainer(for: Journal.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let sample = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec odio. Quisque volutpat mattis eros. Nullam malesuada erat ut turpis. Suspendisse urna nibh viverra non"
    container.mainContext.insert(Journal(title: "My Birthday", content: sample, isBookmarked: true))
    container.mainContext.insert(Journal(title: "Today's Journal", content: sample))
    container.mainContext.insert(Journal(title: "Great Day", content: sample))
    return MainJournalView()
        .environmentObject(JournalViewModel())
        .modelContainer(container)
}
