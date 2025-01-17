//
//  BookController.swift
//  Reading List
//
//  Created by Jessie Ann Griffin on 8/11/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class BookController {
    // MARK: Properties
    // initialize an empty array of books
    private(set) var books: [Book] = []
    // create a computed property where the list will be saved on the device
    private var readingListURL: URL? {
        let fileManager = FileManager.default
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documents.appendingPathComponent("ReadingList.plist")
    }
    
    var readBooks: [Book] {
        return books.filter { $0.hasBeenRead == true }
    }
    
    var unreadBooks: [Book] {
        return books.filter { $0.hasBeenRead == false }
    }
    
    init() {
        loadFromPersistentStore()
    }
    
    // MARK: Helper Methods
    // method to create a book and store it
    @discardableResult func createBook(title: String, reasonToRead: String, hasBeenRead: Bool) -> Book {
        let book = Book(title: title, reasonToRead: reasonToRead)
        books.append(book)
        saveToPersistentStore()
        return book
    }
    // method to delete a book and store the resulting array
    func deleteBook(book: Book) {
        guard let index = books.firstIndex(of: book) else { return }
        books.remove(at: index)
        saveToPersistentStore()
    }
    // method to update the hasBeenRead property
    func updateHasBeenRead(for book: Book) {
        guard let index = books.firstIndex(of: book) else { return }
        if !books[index].hasBeenRead {
            books[index].hasBeenRead = true
        } else {
            books[index].hasBeenRead = false
        }
        saveToPersistentStore()
    }

    // method to edit the book's title and/or reason to read property
    func updateTitleOrReason(for book: Book) {
        guard let index = books.firstIndex(of: book) else { return }
        books[index].title = book.title
        books[index].reasonToRead = book.reasonToRead
        saveToPersistentStore()
    }
    
    // MARK: Persistent Store
    // method to save data to the url created above
    private func saveToPersistentStore() {
        guard let url = readingListURL else { return }
        
        do {
            let encoder = PropertyListEncoder()
            let booksData = try encoder.encode(books)
            try booksData.write(to: url)
        } catch {
            print("Error saving books data: \(error)")
        }
    }
    // method to load data from the url created when saving the data - this method also checks if the file exists
    private func loadFromPersistentStore() {
        let fileManager = FileManager.default
        
        do {
            guard let url = readingListURL, fileManager.fileExists(atPath: url.path) else { return }
            let decodedBooks = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            books = try decoder.decode([Book].self, from: decodedBooks)
        } catch {
            print("Error loading/decoding list of books: \(error)")
        }
    }
    
}
