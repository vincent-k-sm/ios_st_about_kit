//
//  InquiryHistoryStore.swift
//  STAboutKit
//

import Foundation

final class InquiryHistoryStore {
    deinit { }

    static let shared = InquiryHistoryStore()

    private let fileName = "inquiry_history.json"

    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(self.fileName)
    }

    private init() { }

    // MARK: - Public Methods

    func save(_ record: InquiryRecord) {
        var records = self.fetchAll()
        records.insert(record, at: 0)
        self.writeRecords(records)
    }

    func fetchAll() -> [InquiryRecord] {
        guard FileManager.default.fileExists(atPath: self.fileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: self.fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([InquiryRecord].self, from: data)
        }
        catch {
            return []
        }
    }

    func update(_ record: InquiryRecord) {
        var records = self.fetchAll()
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
            self.writeRecords(records)
        }
    }

    func deleteAll() {
        try? FileManager.default.removeItem(at: self.fileURL)
    }

    /// 서버 레코드와 로컬 레코드 병합
    /// - 로컬에 없는 서버 레코드 추가 (outbound 포함)
    /// - 로컬에 있는 레코드는 서버 상태로 업데이트
    func merge(_ serverRecords: [InquiryRecord]) {
        var localRecords = self.fetchAll()
        var changed = false

        for serverRecord in serverRecords {
            if let index = localRecords.firstIndex(where: { $0.id == serverRecord.id }) {
                // 로컬에 있으면 상태 업데이트
                if localRecords[index].status != serverRecord.status
                    || localRecords[index].reply != serverRecord.reply {
                    localRecords[index].status = serverRecord.status
                    localRecords[index].reply = serverRecord.reply
                    localRecords[index].repliedAt = serverRecord.repliedAt
                    changed = true
                }
            }
            else {
                // 로컬에 없으면 추가 (outbound 또는 복원)
                localRecords.append(serverRecord)
                changed = true
            }
        }

        if changed {
            // 최신순 정렬
            localRecords.sort { $0.createdAt > $1.createdAt }
            self.writeRecords(localRecords)
        }
    }

    // MARK: - Private Methods

    private func writeRecords(_ records: [InquiryRecord]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(records)
            try data.write(to: self.fileURL, options: .atomic)
        }
        catch {
            // 저장 실패 시 무시
        }
    }
}
