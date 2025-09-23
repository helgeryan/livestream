//
//  ArticleDetailView.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 9/17/25.
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image if available
            if let imageURL = article.urlToImage {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .clipped()
                            .cornerRadius(12)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            // Title
            Text(article.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            // Author
            if let author = article.author {
                Text("By \(author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Description
            if let description = article.description {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // Published Date
            if let date = formattedDate(from: article.publishedAt) {
                Text(date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // Helper to parse ISO8601 -> custom format
    private func formattedDate(from string: String) -> String? {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: string) {
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d/yyyy" // no leading zeros
            return formatter.string(from: date)
        }
        return nil
    }
}

struct ArticleRowView: View {
    var article: Article
    
    var body: some View {
        NavigationLink(value: article) {
            HStack(alignment: .top) {
                VStack(spacing: 0) {
                    AsyncImage(url: article.urlToImage) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                    
                    Spacer()
                }
                .padding(.trailing, 16)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(article.title)
                        .font(.headline)
                    
                    if let description = article.description {
                        Text(description)
                            .font(.caption)
                            .lineLimit(3)
                            .padding(.top, 5)
                    }
                    
                    if let author = article.author {
                        Text(author)
                            .foregroundStyle(.secondary)
                            .font(.caption2)
                            .padding(.top, 5)
                    }
                }
                .tint(.primary)
            }
        }
        .padding(.top)
    }
}
