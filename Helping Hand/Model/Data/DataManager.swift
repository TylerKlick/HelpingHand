//
//  DataManager.swift
//

import Foundation
import SwiftData

@MainActor
final class DataManager: ObservableObject {

    // MARK: ‑- Published state for the UI
    @Published var sessions: [Session] = []
    @Published var currentSession: Session?
    @Published var settings: SessionSettings

    // MARK: ‑- SwiftData stack
    private let container: ModelContainer
    private let context: ModelContext

    // MARK: ‑- Init & Bootstrap
    init() throws {
        let schema = Schema([Session.self, DataFrame.self, SessionSettings.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        container = try ModelContainer(for: schema, configurations: config)
        context = container.mainContext

        // Load or create settings
        if let existing = try context.fetch(FetchDescriptor<SessionSettings>()).first {
            settings = existing
        } else {
            settings = SessionSettings(channelMap_: ChannelMap(payload: [:]),
                                       windowType_: "hamming")
            context.insert(settings)
            try context.save()
        }

        refreshSessions()
        ensureFreshSession()
    }

    // MARK: ‑- Session CRUD
    func refreshSessions() {
        sessions = (try? context.fetch(FetchDescriptor<Session>())) ?? []
    }

    func createSession() throws -> Session {
        let now = Date()
        let session = Session(endTime_: now,
                              mode_: settings.windowType_,
                              sessionID_: UUID(),
                              startTime_: now)
        context.insert(session)
        try context.save()
        refreshSessions()
        currentSession = session
        return session
    }

    func deleteSession(_ session: Session) throws {
        context.delete(session)
        try context.save()
        refreshSessions()
        if currentSession?.sessionID_ == session.sessionID_ {
            currentSession = sessions.first
        }
    }

    // MARK: ‑- DataFrame CRUD
    func createFrame(label: String,
                     mode: Mode,
                     imuData: Data,
                     sEMGData: Data) throws -> DataFrame {
        guard let session = currentSession else { throw CocoaError(.fileNoSuchFile) }

        let frame = DataFrame(label_: label,
                              mode_: mode,
                              frameID_: UUID(),
                              imuData_: imuData,
                              sEMGData_: sEMGData,
                              timeStamp_: Date())
        frame.session = session
        session.frames?.append(frame)
        try context.save()
        return frame
    }

    func frames(in session: Session) -> [DataFrame] {
        (session.frames ?? []).sorted { $0.timeStamp_ < $1.timeStamp_ }
    }

    func deleteFrame(_ frame: DataFrame) throws {
        context.delete(frame)
        try context.save()
    }

    // MARK: ‑- Filtering
    func frames(label: String? = nil,
                from start: Date? = nil,
                to end: Date? = nil,
                in session: Session) -> [DataFrame] {
        frames(in: session).filter {
            (label == nil || $0.label_ == label) &&
            (start == nil || $0.timeStamp_ >= start!) &&
            (end == nil || $0.timeStamp_ <= end!)
        }
    }

    // MARK: ‑- Settings Update
    func updateSettings(
        channelMap: [String: Int],
        sEMGSampleRate: Double,
        imuSampleRate: Double,
        overlapRatio: Float,
        windowSize: Int32,
        windowType: String
    ) throws {
        settings.channelMap_ = ChannelMap(payload: channelMap)
        settings.sEMGSampleRate_ = sEMGSampleRate
        settings.imuSampleRate_ = imuSampleRate
        settings.overlapRatio_ = overlapRatio
        settings.windowSize_ = windowSize
        settings.windowType_ = windowType
        try context.save()

        // A settings change starts a brand-new session
        try createSession()
    }

    // MARK: ‑- Private helpers
    private func ensureFreshSession() {
        if currentSession == nil {
            try? createSession()
        }
    }
}
