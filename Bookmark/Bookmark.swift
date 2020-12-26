//
//  Bookmark.swift
//  Bookmark
//
//  Created by scchn on 2020/12/26.
//  Copyright © 2020 scchn. All rights reserved.
//

import Foundation

// com.apple.security.files.user-selected.read-write
// com.apple.security.files.bookmarks.app-scope
public final class Bookmark {
    
    private typealias Bookmarks = [URL: Data]
    
    private var bookmarks: Bookmarks = [:]
    
    public let bookmarkURL: URL
    
    public var urls: [URL] { bookmarks.map(\.key) }
    
    public init(at url: URL) throws {
        bookmarkURL = url
        try createBookmarkFileIfNeeded()
        try loadBookmarks()
    }
    
    private func createBookmarkFileIfNeeded() throws {
        if !FileManager.default.fileExists(atPath: bookmarkURL.path) {
            try saveBookmarks()
        } 
    }
    
    private func loadBookmarks() throws {
        let data = try Data(contentsOf: bookmarkURL)
        let bookmarks = try NSKeyedUnarchiver
            .unarchiveTopLevelObjectWithData(data) as? Bookmarks ?? [:]
        
        for (_, data) in bookmarks {
            var isStale = false
            
            do {
                let url = try URL(
                    resolvingBookmarkData: data,
                    options: .withSecurityScope,
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                )
                
                if !isStale && url.startAccessingSecurityScopedResource() {
                    self.bookmarks[url] = data
                }
            } catch {
                
            }
        }
    }
    
    private func saveBookmarks() throws {
        do {
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: bookmarks,
                requiringSecureCoding: false
            )
            try data.write(to: bookmarkURL)
        } catch {
            
        }
    }
    
    public func bookmarkExists(url: URL) -> Bool {
        do {
            _ = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            return true
        } catch {
            return false
        }
    }
    
    @discardableResult
    public func addBookmark(for url: URL) -> Bool {
        guard !urls.contains(url) else { return true }
        
        do {
            let data = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            
            guard bookmarks[url] != data else { return true }
            
            bookmarks[url] = data
            try saveBookmarks()
            return true
        } catch {
            return false
        }
    }
    
    public func removeBookmark(for url: URL) -> URL? {
        guard bookmarks.removeValue(forKey: url) != nil
        else { return nil }
        do {
            url.stopAccessingSecurityScopedResource()
            try saveBookmarks()
            return url
        } catch {
            return nil
        }
    }
    
}
