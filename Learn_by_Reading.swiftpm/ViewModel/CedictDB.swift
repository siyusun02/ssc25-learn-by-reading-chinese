import SQLite3
import Foundation
import SwiftUI

class CedictDB: ObservableObject {
    private var db: OpaquePointer?
    var maxWordLength: Int = 19

    init() {
        openDatabase()
        
        if let len = getMaxWordLength() {
            self.maxWordLength = len
        }
    }

    private func openDatabase() {
        guard let dbPath = Bundle.main.path(forResource: "cedict", ofType: "sqlite") else {
            print("ERROR: cedict.sqlite not found")
            return
        }

        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("INFO: Successfully opened cedict database")
        } else {
            print("ERROR: Failed to open database")
            db = nil
        }
    }

    private func executeQuery(_ query: String, binding: (OpaquePointer?) -> Void) -> [CedictEntry] {
        var statement: OpaquePointer?
        var results: [CedictEntry] = []

        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            print("ERROR: Failed to prepare statement")
            return results
        }

        binding(statement)

        while sqlite3_step(statement) == SQLITE_ROW {
            results.append(CedictEntry(
                id: Int(sqlite3_column_int(statement, 0)),
                    traditional: sqlite3_column_text(statement, 1).flatMap { String(cString: $0) } ?? "",
                    simplified: sqlite3_column_text(statement, 2).flatMap { String(cString: $0) } ?? "",
                    definition: sqlite3_column_text(statement, 4).flatMap { String(cString: $0) } ?? "",
                    pinyinRaw: sqlite3_column_text(statement, 3).flatMap { String(cString: $0) } ?? ""
            ))
        }

        sqlite3_finalize(statement)
        return results
    }

    private func getMaxWordLength() -> Int? {
        let query = """
            SELECT MAX(LENGTH(traditional)), MAX(LENGTH(simplified))
            FROM dictionary;
        """
        
        var statement: OpaquePointer?
        var maxLength: Int? = nil

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                let maxTraditional = Int(sqlite3_column_int(statement, 0))
                let maxSimplified = Int(sqlite3_column_int(statement, 1))
                maxLength = max(maxTraditional, maxSimplified)
            }
        } else {
            print("ERROR: Failed to prepare statement for max word length")
        }

        sqlite3_finalize(statement)
        return maxLength
    }
    
    func searchExact(word: String) -> CedictEntry? {
        let normalized = word.precomposedStringWithCompatibilityMapping

        let query = """
            SELECT id, traditional, simplified, pinyin, GROUP_CONCAT(definition, '\n')
            FROM dictionary
            WHERE traditional LIKE ? OR simplified LIKE ?
            GROUP BY simplified
            ORDER BY length(simplified)
            LIMIT 10
            """
        
        let results = executeQuery(query) { statement in
            sqlite3_bind_text(statement, 1, (normalized as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (normalized as NSString).utf8String, -1, nil)
        }

        if results.count > 1 {
            print("WARN: Found multiple exact matches for '\(word)', returning the first")
        }
        
        if results.count == 0 {
            print("WARN: No exact match for '\(word)'")
        }

        return results.first
    }
    
    func searchExact(words: [String]) -> [String: CedictEntry] {
        var results: [String: CedictEntry] = [:]

        let placeholdersInputList = words.map { word in
            return "SELECT ? AS input_char"
        }.joined(separator: " UNION ALL ")
        
        let query = """
            WITH input_list AS (
                \(placeholdersInputList)
            )
            SELECT 
                d.id, 
                d.traditional, 
                d.simplified, 
                d.pinyin, 
                GROUP_CONCAT(d.definition, CHAR(10)) AS definitions
            FROM input_list i
            LEFT JOIN dictionary d 
                ON i.input_char = d.simplified 
                OR i.input_char = d.traditional
            GROUP BY i.input_char, d.id;
            """
        
        let resultsFromQuery = executeQuery(query) { statement in
            for (index, word) in words.enumerated() {
                sqlite3_bind_text(statement, Int32(index + 1), (word.precomposedStringWithCompatibilityMapping as NSString).utf8String, -1, nil)
            }
            
            for (index, word) in words.enumerated() {
                sqlite3_bind_text(statement, Int32(words.count + index + 1), (word.precomposedStringWithCompatibilityMapping as NSString).utf8String, -1, nil)
            }
        }

        for entry in resultsFromQuery {
            results[entry.simplified] = entry
            results[entry.traditional] = entry
        }

        return results
    }
    
    func search(word: String) -> [CedictEntry] {
        let normalized = word.precomposedStringWithCompatibilityMapping
        
        let query = """
            SELECT id, traditional, simplified, pinyin, definition 
            FROM dictionary 
            WHERE traditional LIKE ? OR simplified LIKE ? 
            ORDER BY length(simplified) ASC 
            LIMIT 10;
            """

        return executeQuery(query) { statement in
            let searchPattern = "%\(normalized)%" as NSString
            sqlite3_bind_text(statement, 1, searchPattern.utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, searchPattern.utf8String, -1, nil)
        }
    }
    
    func searchByAnyField(searchTerm: String) -> [CedictEntry] {
            let normalized = searchTerm.precomposedStringWithCompatibilityMapping
            
            let query = """
                SELECT id, traditional, simplified, pinyin, GROUP_CONCAT(definition, '\n') AS definitions
                FROM dictionary
                WHERE
                    simplified LIKE ? OR
                    traditional LIKE ? OR
                    pinyin LIKE ? OR
                    definition LIKE ?
                GROUP BY id
                ORDER BY 
                    CASE
                        WHEN simplified LIKE ? THEN 0
                        WHEN traditional LIKE ? THEN 0
                        WHEN pinyin LIKE ? THEN 0
                        WHEN definitions LIKE ? THEN 1
                        WHEN simplified LIKE ? THEN 2
                        WHEN traditional LIKE ? THEN 2
                        WHEN pinyin LIKE ? THEN 2
                        ELSE 3
                    END, length(simplified)
                LIMIT 30;
                """

            return executeQuery(query) { statement in
                let searchPattern = "%\(normalized)%" as NSString
                let exactNormalized = normalized as NSString
                sqlite3_bind_text(statement, 1, searchPattern.utf8String, -1, nil)
                sqlite3_bind_text(statement, 2, searchPattern.utf8String, -1, nil)
                sqlite3_bind_text(statement, 3, searchPattern.utf8String, -1, nil)
                sqlite3_bind_text(statement, 4, searchPattern.utf8String, -1, nil)
                
                sqlite3_bind_text(statement, 5, exactNormalized.utf8String, -1, nil)
                sqlite3_bind_text(statement, 6, exactNormalized.utf8String, -1, nil)
                sqlite3_bind_text(statement, 7, exactNormalized.utf8String, -1, nil)
                sqlite3_bind_text(statement, 8, exactNormalized.utf8String, -1, nil)
                
                sqlite3_bind_text(statement, 9, searchPattern.utf8String, -1, nil)
                sqlite3_bind_text(statement, 10, searchPattern.utf8String, -1, nil)
                sqlite3_bind_text(statement, 11, searchPattern.utf8String, -1, nil)
            }
        }
    
    deinit {
        sqlite3_close(db)
    }
}
