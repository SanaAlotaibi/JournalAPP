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

// enum: نوع فيه خيارات محددة فقط
// هنا خيارات الترتيب اللي تطلع في قائمة الفلتر
enum SortOption {
    case bookmark
    case entryDate
}
// الـ ViewModel (الـ VM في MVVM)
class JournalViewModel: ObservableObject {

    // النص اللي يكتبه المستخدم في خانة البحث
    @Published var searchText: String = ""

    // نوع الترتيب الحالي (يبدأ بالتاريخ)
    @Published var sortOption: SortOption = .entryDate

    // فنكشن تستقبل كل الجورنالز من الداتابيس وتحطهم بالاراي
    func filteredJournals(from journals: [Journal]) -> [Journal] {
        // ناخذ نسخه من الجورنالز داخل المتغير ذا وبنشتغل عليه
        var result = journals

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }

        // 2) الترتيب حسب الخيار المختار
        switch sortOption {
        case .entryDate:
            // الأحدث أولاً
            result.sort { $0.date > $1.date }
        case .bookmark:
            // المحفوظة أولاً، وإذا الاثنين نفس الحالة نرتبهم بالتاريخ
            result.sort {
                if $0.isBookmarked != $1.isBookmarked { return $0.isBookmarked }
                return $0.date > $1.date
            }
        }
        return result
    }

    // نضيف جورنال جديدة للداتابيس
    // context = الاتصال بالداتابيس (SwiftData)
    func addJournal(title: String, content: String, context: ModelContext) {
        let newJournal = Journal(title: title, content: content)
        context.insert(newJournal)
    }

    // ما نحتاج نستدعي save لأن Journal كلاس و SwiftData يحفظ التعديل تلقائياً
    func updateJournal(_ journal: Journal, title: String, content: String) {
        journal.title = title
        journal.content = content
    }

    func deleteJournal(_ journal: Journal, context: ModelContext) {
        context.delete(journal)
    }

    // تقلب حالة البوكمارك: إذا محفوظة تصير غير محفوظة، والعكس
    func toggleBookmark(for journal: Journal) {
        journal.isBookmarked.toggle()
    }
}
