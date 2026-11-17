//
//  Journal.swift
//  JournalSana
//
//  Created by Sana Alotaibi on 01/06/1448 AH.
//

import Foundation
import SwiftData

// ─────────────────────────────────────────────
// الـ Model (الـ M في MVVM)
// هذا شكل المذكرة الواحدة: عنوان، محتوى، تاريخ، وهل هي محفوظة (Bookmark)
//
// ليش class مو struct؟
// لأن SwiftData يحتاج class عشان يتابع أي تغيير ويحفظه تلقائياً.
// الـ class "مرجع" (Reference type): لو عدّلنا المذكرة في مكان، يتعدّل الأصل نفسه.
// ─────────────────────────────────────────────

// @Model = SwiftData يحفظ هذا الكلاس تلقائياً في داتابيس على الجهاز
@Model
final class Journal {
    var title: String         // عنوان المذكرة
    var content: String       // نص المذكرة
    var date: Date            // تاريخ إنشاء المذكرة
    var isBookmarked: Bool    // true = محفوظة بالبوكمارك

    // init: الدالة اللي تنشئ مذكرة جديدة
    // date و isBookmarked لهم قيم افتراضية (تاريخ اليوم، وغير محفوظة)
    // عشان كذا نقدر ننشئ مذكرة بالعنوان والمحتوى بس
    init(title: String, content: String, date: Date = Date(), isBookmarked: Bool = false) {
        self.title = title
        self.content = content
        self.date = date
        self.isBookmarked = isBookmarked
    }
}
