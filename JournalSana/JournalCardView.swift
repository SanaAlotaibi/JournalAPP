//
//  JournalCardView.swift
//  JournalSana
//

import SwiftUI
import SwiftData

// ─────────────────────────────────────────────
// كرت المذكرة الواحدة في القائمة (View)
// يعرض: العنوان، أيقونة البوكمارك، التاريخ، وأول 5 أسطر من المحتوى
// struct لأن الواجهات في SwiftUI خفيفة وتنعاد رسمها كثير
// ─────────────────────────────────────────────
struct JournalCardView: View {
    // المذكرة اللي نعرضها (let لأن الكرت ما يغيّرها بنفسه)
    let journal: Journal

    // closure: دالة نستقبلها من الصفحة الرئيسية، تنفّذ لما نضغط البوكمارك
    // كذا الكرت ما يعرف شي عن الـ ViewModel، بس يبلّغ إن صار ضغط
    var onBookmarkTap: () -> Void

    // body: شكل الكرت
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            // السطر الأول: العنوان على اليسار والبوكمارك على اليمين
            HStack(alignment: .top) {
                // إذا العنوان فاضي نكتب "Untitled"
                Text(journal.title.isEmpty ? "Untitled" : journal.title)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color("TextAccent"))
                    .lineLimit(1)

                Spacer() // يدفع البوكمارك لأقصى اليمين

                // زر البوكمارك: الأيقونة ممتلئة إذا المذكرة محفوظة، وفاضية إذا لا
                Button(action: onBookmarkTap) {
                    Image(systemName: journal.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(Color("TextAccent"))
                        // مساحة ضغط أكبر (44 نقطة) عشان يسهل الضغط على الأيقونة
                        .frame(width: 44, height: 44, alignment: .topTrailing)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(journal.isBookmarked ? "Remove Bookmark" : "Bookmark")
                .buttonStyle(.plain) // عشان الضغط على الأيقونة ما يفتح المذكرة
                // نرجّع ارتفاع السطر مثل ما كان عشان التاريخ ما ينزل
                .padding(.bottom, -14)
            }

            // التاريخ بصيغة يوم/شهر/سنة (حسب إعدادات الجهاز)
            Text(journal.date.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year()))
                .font(.system(size: 14))
                .foregroundColor(Color("TextSecondary"))

            // المحتوى: نعرض 5 أسطر بس، والباقي يطلع "..."
            Text(journal.content)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .lineLimit(5)
                .padding(.top, 16)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading) // الكرت ياخذ عرض الشاشة كامل
        .background(Color("SurfaceCard"))
        .clipShape(RoundedRectangle(cornerRadius: 24))   // زوايا دائرية
    }
}

#Preview {
    JournalCardView(
        journal: Journal(title: "My Birthday", content: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit.", isBookmarked: true),
        onBookmarkTap: {}
    )
    .padding()
    .background(Color.black)
    .modelContainer(for: Journal.self, inMemory: true)
}
