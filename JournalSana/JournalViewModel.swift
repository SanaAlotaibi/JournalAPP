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

// ─────────────────────────────────────────────
// enum: نوع فيه خيارات محددة فقط
// هنا خيارات الترتيب اللي تطلع في قائمة الفلتر
// ─────────────────────────────────────────────
enum SortOption {
    case bookmark     // ترتيب حسب البوكمارك (المحفوظة أول)
    case entryDate    // ترتيب حسب التاريخ (الأحدث أول)
}

// ─────────────────────────────────────────────
// الـ ViewModel (الـ VM في MVVM)
// فيه "المنطق": البحث، الترتيب، الإضافة، التعديل، الحذف
// الواجهات (Views) ما تسوي هالأشياء بنفسها، تطلبها من هنا
//
// ObservableObject: أي تغيير في المتغيرات اللي عليها @Published
// يخلي الواجهات اللي تستخدم الـ ViewModel تتحدث تلقائياً
// ─────────────────────────────────────────────
class JournalViewModel: ObservableObject {

    // النص اللي يكتبه المستخدم في خانة البحث
    @Published var searchText: String = ""

    // نوع الترتيب الحالي (يبدأ بالتاريخ)
    @Published var sortOption: SortOption = .entryDate

    // ترجع المذكرات بعد البحث والترتيب، وهذي اللي تنعرض في القائمة
    // تاخذ كل المذكرات من الداتابيس، وترجع نسخة مفلترة ومرتبة
    func filteredJournals(from journals: [Journal]) -> [Journal] {
        var result = journals

        // 1) البحث: إذا فيه نص بحث، نخلي بس المذكرات اللي عنوانها أو محتواها فيه النص
        //    (localizedCaseInsensitiveContains = ما يفرق بين الحروف الكبيرة والصغيرة)
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

    // تضيف مذكرة جديدة للداتابيس
    // context = الاتصال بالداتابيس (SwiftData)، insert تحفظ المذكرة فيه
    func addJournal(title: String, content: String, context: ModelContext) {
        let newJournal = Journal(title: title, content: content)
        context.insert(newJournal)
    }

    // تعدّل عنوان ومحتوى مذكرة موجودة
    // ما نحتاج نستدعي save لأن Journal كلاس و SwiftData يحفظ التعديل تلقائياً
    func updateJournal(_ journal: Journal, title: String, content: String) {
        journal.title = title
        journal.content = content
    }

    // تحذف المذكرة من الداتابيس
    func deleteJournal(_ journal: Journal, context: ModelContext) {
        context.delete(journal)
    }

    // تقلب حالة البوكمارك: إذا محفوظة تصير غير محفوظة، والعكس
    func toggleBookmark(for journal: Journal) {
        journal.isBookmarked.toggle()
    }
}
