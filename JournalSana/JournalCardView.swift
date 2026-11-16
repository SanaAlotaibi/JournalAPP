//
//  JournalCardView.swift
//  JournalSana
//

import SwiftUI
import SwiftData

// كرت المذكرة في القائمة
struct JournalCardView: View {
    let journal: Journal
    var onBookmarkTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                Text(journal.title.isEmpty ? "Untitled" : journal.title)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color("TextAccent"))
                    .lineLimit(1)

                Spacer()

                Button(action: onBookmarkTap) {
                    Image(systemName: journal.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(Color("TextAccent"))
                }
                .buttonStyle(.plain) // عشان الضغط على الأيقونة ما يفتح المذكرة
            }

            Text(journal.date.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year()))
                .font(.system(size: 14))
                .foregroundColor(Color("TextSecondary"))

            Text(journal.content)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .lineLimit(5)
                .padding(.top, 16)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("SurfaceCard"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
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
