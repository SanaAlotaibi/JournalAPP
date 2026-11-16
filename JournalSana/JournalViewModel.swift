//
//  JournalViewModel.swift
//  JournalSana
//
//  Created by Sana Alotaibi on 01/06/1448 AH.
//
import Foundation
import SwiftUI
import SwiftData
import Combine

// خيارات الترتيب في قائمة الفلتر
enum SortOption {
    case bookmark
    case entryDate
}

// الـ ViewModel فيه المنطق (بحث، ترتيب، إضافة، حذف)
// والمذكرات نفسها محفوظة في SwiftData ونجيبها بـ @Query في الواجهة
class JournalViewModel: ObservableObject {

    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .entryDate

    // المذكرات بعد البحث والترتيب — هذي اللي تنعرض في القائمة
    func filteredJournals(from journals: [Journal]) -> [Journal] {
        var result = journals

        // البحث في العنوان والمحتوى
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch sortOption {
        case .entryDate:
            // الأحدث أولاً
            result.sort { $0.date > $1.date }
        case .bookmark:
            // المحفوظة أولاً، وبعدها حسب التاريخ
            result.sort {
                if $0.isBookmarked != $1.isBookmarked { return $0.isBookmarked }
                return $0.date > $1.date
            }
        }
        return result
    }

    func addJournal(title: String, content: String, context: ModelContext) {
        let newJournal = Journal(title: title, content: content)
        context.insert(newJournal)
    }

    func updateJournal(_ journal: Journal, title: String, content: String) {
        // Journal كلاس، فالتعديل عليه يتحفظ تلقائياً
        journal.title = title
        journal.content = content
    }

    func deleteJournal(_ journal: Journal, context: ModelContext) {
        context.delete(journal)
    }

    func toggleBookmark(for journal: Journal) {
        journal.isBookmarked.toggle()
    }
}
