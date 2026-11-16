//
//  Journal.swift
//  JournalSana
//
//  Created by Sana Alotaibi on 01/06/1448 AH.
//
//  Journal.swift
//  JournalSana
//

import Foundation
import SwiftData

// @Model = SwiftData يحفظ هذا الكلاس تلقائياً على الجهاز
@Model
final class Journal {
    var title: String
    var content: String
    var date: Date
    var isBookmarked: Bool

    init(title: String, content: String, date: Date = Date(), isBookmarked: Bool = false) {
        self.title = title
        self.content = content
        self.date = date
        self.isBookmarked = isBookmarked
    }
}
