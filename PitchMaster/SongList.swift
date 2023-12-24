//
//  SongList.swift
//  Time
//
//  Created by Lixing Liu on 12/10/23.
//
import CoreData
import Foundation
import SwiftUI

struct SonglistView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var settings: Settings
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Song.name, ascending: true)],
        animation: .default)
    private var songs: FetchedResults<Song>

    @State private var newItemName = ""
    @State private var newItemDetails = ""
    @State private var isAddingItem = false

    var body: some View {
        NavigationView {
            List {
                ForEach(songs) { song in
                    NavigationLink(destination: SongDetailView(song: song).environmentObject(settings)) {
                        Text("\(song.name ?? "")")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Song List")
            .navigationBarItems(trailing:
                Button(action: {
                    isAddingItem = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $isAddingItem, content: {
                AddSongView(isPresented: $isAddingItem)
                    .environment(\.managedObjectContext, viewContext)
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }


    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { songs[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct SonglistView_Previews: PreviewProvider {
    static var previews: some View {
        SonglistView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
