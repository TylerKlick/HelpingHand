////
////  ContentView.swift
////  Helping Hand
////
////  Created by Tyler Klick on 6/12/25.
////
//
//import SwiftUI
//internal import FluidGradient
//internal import SwiftUIVisualEffects
//
//struct MeshGradientBackground: View {
//    var body: some View {
//        MeshGradient(
//            width: 2, height: 2,
//            points: [
//                [0, 0], [1, 0],
//                [0, 1], [1, 1]
//            ],
//            colors: [
//                .indigo, .cyan,
//                .purple, .pink
//            ]
//        )
//        .ignoresSafeArea()
//    }
//}
//
//struct ContentView: View {
//    
//    var body: some View {
//        
//        
////        FluidGradient(
////            blobs: [.purple, .cyan, .indigo],
////            highlights: [.green.opacity(0.8)],
////            speed: 0.1,
////            blur: 0.9
////        )
////        .ignoresSafeArea()
////        .overlay(
////         )
//        
////        let tabItems = [
////            CustomTabItem(
////                systemImageName: "house",
////                title: "Home",
////                backgroundGradient: LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
////            ) {
////                
////                MeshGradientBackground()
////                    .ignoresSafeArea()
////                    .overlay(
////                        MyDeviceView()
////                    )
////            }
////
////        ]
////        
////        CustomTabView(items: tabItems)
//        PersistenceTestView()
//    }
//}
//
//#Preview {
//    ContentView()
//}


//
//  ContentView.swift
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var dm = try! DataManager()

    var body: some View {
        NavigationSplitView {
            // Left column – Sessions
            List(selection: $dm.currentSession) {
                ForEach(dm.sessions) { session in
                    NavigationLink(value: session) {
                        VStack(alignment: .leading) {
                            Text("Session \(session.sessionID_.uuidString.prefix(4))")
                            Text(session.startTime_, style: .time)
                                .font(.caption)
                        }
                    }
                }
                .onDelete(perform: deleteSessions)
            }
            .navigationTitle("Sessions")
            .toolbar {
                Button("New") { try? dm.createSession() }
            }
        } detail: {
            // Right column – Frames or Settings
            if let session = dm.currentSession {
                FrameListView(session: session)
            } else {
                DSettingsView()
            }
        }
        .environmentObject(dm)
    }

    private func deleteSessions(at offsets: IndexSet) {
        offsets.map { dm.sessions[$0] }.forEach { try? dm.deleteSession($0) }
    }
}

// MARK: - Settings Editor
struct DSettingsView: View {
    @EnvironmentObject var dm: DataManager
    @State private var mapKey = ""
    @State private var mapValue = 0
    @State private var sEMG = 1000.0
    @State private var imu = 1000.0
    @State private var overlap = 0.5
    @State private var windowSize = 32
    @State private var windowType = "hamming"

    var body: some View {
        Form {
            Section("Channel Map") {
                HStack {
                    TextField("Key", text: $mapKey)
                    Stepper("Value \(mapValue)", value: $mapValue)
                    Button("Add") {
                        var map = dm.settings.channelMap_.payload
                        map[mapKey] = mapValue
                        try? dm.updateSettings(channelMap: map,
                                               sEMGSampleRate: sEMG,
                                               imuSampleRate: imu,
                                               overlapRatio: Float(overlap),
                                               windowSize: Int32(windowSize),
                                               windowType: windowType)
                        mapKey = ""
                    }
                }
                ForEach(Array(dm.settings.channelMap_.payload.keys), id: \.self) { key in
                    HStack {
                        Text(key)
                        Spacer()
                        Text("\(dm.settings.channelMap_.payload[key]!)")
                    }
                }
            }

            Section("Sampling") {
                Slider(value: $sEMG, in: 100...5000, step: 100) { Text("sEMG \(sEMG, specifier: "%.0f") Hz") }
                Slider(value: $imu, in: 100...5000, step: 100) { Text("IMU \(imu, specifier: "%.0f") Hz") }
                Slider(value: $overlap, in: 0...1) { Text("Overlap \(overlap, specifier: "%.2f")") }
                Stepper("Window Size \(windowSize)", value: $windowSize, in: 8...512)
                TextField("Window Type", text: $windowType)
            }

            Button("Save & Start New Session") {
                try? dm.updateSettings(channelMap: dm.settings.channelMap_.payload,
                                       sEMGSampleRate: sEMG,
                                       imuSampleRate: imu,
                                       overlapRatio: Float(overlap),
                                       windowSize: Int32(windowSize),
                                       windowType: windowType)
            }
        }
        .navigationTitle("Settings")
    }
}

// MARK: - Frame List
struct FrameListView: View {
    let session: Session
    @EnvironmentObject var dm: DataManager
    @State private var labelFilter = ""

    private var frames: [DataFrame] {
        dm.frames(label: labelFilter.isEmpty ? nil : labelFilter, in: session)
    }

    var body: some View {
        List {
            Section("Filter") {
                TextField("Label filter", text: $labelFilter)
            }
            Section("Frames (\(frames.count))") {
                ForEach(frames) { frame in
                    VStack(alignment: .leading) {
                        Text("Label: \(frame.label_)")
                        Text(frame.timeStamp_, style: .time)
                            .font(.caption)
                    }
                }
                .onDelete(perform: deleteFrames)
            }
        }
        .navigationTitle("Frames")
        .toolbar {
            Button("Add Dummy Frame") {
                try? dm.createFrame(label: "test-\(Int.random(in: 0...9))",
                                    mode: .training,
                                    imuData: Data("imu".utf8),
                                    sEMGData: Data("semg".utf8))
            }
        }
    }

    private func deleteFrames(at offsets: IndexSet) {
        offsets.map { frames[$0] }.forEach { try? dm.deleteFrame($0) }
    }
}
