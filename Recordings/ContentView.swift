//
//  ContentView.swift
//  Recordings
//
//  Created by Florian Kugler on 20-03-2020.
//  Copyright © 2020 objc.io. All rights reserved.
//

import SwiftUI

extension Item {
    var destination: some View {
        Group {
            if self is Folder {
                FolderList(folder: self as! Folder)
            } else {
                Text("Player: \(self.name)")
            }
        }
    }
}

struct FolderList: View {
    @ObservedObject var folder: Folder
    @State var presentsNewRecording = false
    var body: some View {
        List {
            ForEach(folder.contents) { item in
                NavigationLink(destination: item.destination) {
                    Text(item.name)
                }
            }.onDelete(perform: { indices in
                let items = indices.map { self.folder.contents[$0] }
                for item in items {
                    self.folder.remove(item)
                }
            })
        }
        .navigationBarTitle("Recordings")
        .navigationBarItems(trailing: HStack {
            Button(action: {
                self.folder.add(Folder(name: "New Folder \(self.folder.contents.count)", uuid: UUID()))
            }, label: {
                Image(systemName: "folder.badge.plus")
            })
            Button(action: {
                self.presentsNewRecording = true
            }, label: {
                Image(systemName: "waveform.path.badge.plus")
            })
        })
        .sheet(isPresented: $presentsNewRecording) {
            RecordingView(folder: self.folder)
        }
    }
}

struct RecordingView: View {
    let folder: Folder
    private let recording = Recording(name: "", uuid: UUID())
    @State private var recorder: Recorder? = nil
    @State private var time: TimeInterval = 0
    
    var body: some View {
        VStack {
            Text("Recording")
                .font(.title)
            Text(timeString(time))
        }
        .onAppear {
            guard let s = self.folder.store, let url = s.fileURL(for: self.recording) else { return }
            self.recorder = Recorder(url: url) { time in
                self.time = time ?? 0
            }
        }
    }
}

struct ContentView: View {
    let store = Store.shared
    var body: some View {
        NavigationView {
            FolderList(folder: store.rootFolder)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
