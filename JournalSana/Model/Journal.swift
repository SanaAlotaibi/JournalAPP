//
//  Journal.swift
//  JournalSana
//
//  Created by Sana Alotaibi on 01/06/1448 AH.
//

import Foundation
import SwiftData
//the M in MVVM
// استخدنا كلاس مو ستركت لان نبغى لو عدلنا شي يتعدل بنفسه مو نسخه منه في سويفت داتا
// @Model = SwiftData يحفظ هذا الكلاس تلقائياً في داتابيس على الجهاز
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
