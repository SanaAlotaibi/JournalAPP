//
//  MainJournalView.swift
//  JournalSana
//
//  Created by Sana Alotaibi on 02/06/1448 AH.
//

import SwiftUI
import SwiftData

struct MainJournalView: View {
    @EnvironmentObject var viewModel: JournalViewModel
    @Environment(\.modelContext) private var context
    // نجيب المذكرات من SwiftData — تتحدث تلقائياً عند أي إضافة أو تعديل أو حذف
    @Query(sort: \Journal.date, order: .reverse) private var journals: [Journal]
    @State private var showNewJournalSheet = false
    @State private var selectedJournal: Journal?      // المذكرة اللي نعدّلها
    @State private var journalToDelete: Journal?      // المذكرة اللي بنحذفها

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary").ignoresSafeArea()

                if journals.isEmpty {
                    emptyStateView
                } else if viewModel.filteredJournals(from: journals).isEmpty {
                    ContentUnavailableView.search(text: viewModel.searchText)
                } else {
                    journalList
                }
            }
            .navigationTitle("Journal")
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // زر الفلتر
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

                    // زر الإضافة
                    Button {
                        showNewJournalSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search")
            // شيت مذكرة جديدة
            .sheet(isPresented: $showNewJournalSheet) {
                JournalEditorView(journal: nil)
                    .environmentObject(viewModel)
            }
            // شيت تعديل مذكرة
            .sheet(item: $selectedJournal) { journal in
                JournalEditorView(journal: journal)
                    .environmentObject(viewModel)
            }
            // تنبيه الحذف
            .alert("Delete Journal?", isPresented: Binding(
                get: { journalToDelete != nil },
                set: { if !$0 { journalToDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) {
                    journalToDelete = nil
                }
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

    // قائمة المذكرات
    private var journalList: some View {
        List {
            ForEach(viewModel.filteredJournals(from: journals)) { journal in
                JournalCardView(journal: journal) {
                    viewModel.toggleBookmark(for: journal)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedJournal = journal
                }
                // السحب للحذف
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        journalToDelete = journal
                    } label: {
                        Image(systemName: "trash.fill")
                    }
                    .tint(Color("Destructive"))
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    // مكون الواجهة الفارغة (Empty State)
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            // استخدام صورة الدفتر من الـ Assets
            Image("33")
                .resizable()
                .scaledToFit()
                .frame(width: 130, height: 130)

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

#Preview {
    MainJournalView()
        .environmentObject(JournalViewModel())
        .modelContainer(for: Journal.self, inMemory: true)
}

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
