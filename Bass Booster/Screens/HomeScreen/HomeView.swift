import SwiftUI
import CoreData

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State private var showAddPlaylistOverlay = false
    @State private var showBottomSheet = false
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    // Заголовок с возможностью показать кнопку "Назад"
                    HStack {
                        if viewModel.isInGeneralPlaylist {
                            Text("My Player")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.white)
                        } else {
                            Button(action: {
                                withAnimation {
                                    viewModel.goToGeneralPlaylist()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
                                    Text("Back")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .medium))
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    if viewModel.isInGeneralPlaylist {
                        // Горизонтальный список плейлистов только в General
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                // Кнопка для добавления нового плейлиста
                                Button(action: {
                                    showAddPlaylistOverlay = true
                                }) {
                                    VStack {
                                        Image(systemName: "plus")
                                            .font(.largeTitle)
                                            .foregroundColor(.white)
                                        Text("Add playlist")
                                            .foregroundColor(.white)
                                            .font(.caption)
                                    }
                                    .frame(width: 100, height: 100)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                }
                                
                                // Плейлист "General" всегда отображается первым
                                if let generalPlaylist = viewModel.playlists.first(where: { $0.name == "General" }) {
                                    PlaylistCell(playlist: generalPlaylist) {
                                        withAnimation {
                                            viewModel.selectedPlaylist = generalPlaylist
                                            viewModel.fetchMusicFiles(for: generalPlaylist)
                                        }
                                    }
                                }
                                
                                // Остальные плейлисты
                                ForEach(viewModel.playlists.filter { $0.name != "General" }) { playlist in
                                    PlaylistCell(playlist: playlist) {
                                        withAnimation {
                                            viewModel.selectedPlaylist = playlist
                                            viewModel.fetchMusicFiles(for: playlist)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                        
                        // Строка поиска только в General
//                        SearchBarView(searchText: $viewModel.searchText)
//                            .padding(.horizontal)
                    }
                    
                    List {
                        ForEach(viewModel.filteredMusicFiles) { musicFile in
                            MusicFileRow(
                                musicFile: musicFile,
                                playlists: viewModel.playlists.filter { $0.name != "General" },
                                onAddToPlaylist: { song, playlist in
                                    viewModel.addSong(song, to: playlist)
                                },
                                onRename: { song, newName in
                                    viewModel.renameSong(song, to: newName)
                                },
                                onDelete: { song in
                                    viewModel.deleteMusicFileEntity(song)
                                },
                                showBottomSheet: $showBottomSheet
                            )
                        }
                        .onDelete(perform: viewModel.deleteMusicFile)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                    .onAppear {
                        viewModel.fetchSavedMusicFiles()
                        viewModel.fetchPlaylists()
                    }
                    
                    Spacer()
                }
                .hideNavigationBar()
                .padding()
                .background(Color.black)
            }
            
            // Отображаем AddPlaylist поверх HomeView
            if showAddPlaylistOverlay {
                AddPlaylistView(isPresented: $showAddPlaylistOverlay, onAdd: { name in
                    viewModel.addPlaylist(name: name)
                })
                .transition(.move(edge: .bottom))
                .animation(.spring())
            }
        }
    }
}

// Превью для SwiftUI
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = HomeViewModel()
        HomeView(viewModel: viewModel)
    }
}

// MARK: - Дополнительные компоненты

// Компонент MusicFileRow с Bottom Sheet для действий
struct MusicFileRow: View {
    var musicFile: MusicFileEntity
    var playlists: [PlaylistEntity]
    var onAddToPlaylist: (MusicFileEntity, PlaylistEntity) -> Void
    var onRename: (MusicFileEntity, String) -> Void
    var onDelete: (MusicFileEntity) -> Void
    @Binding var showBottomSheet: Bool

    var body: some View {
        HStack {
            Image(systemName: "music.note")
                .foregroundColor(.white)
                .font(.largeTitle)
            VStack(alignment: .leading) {
                Text(musicFile.name ?? "Unknown")
                    .foregroundColor(.white)
                    .font(.headline)
                Text("Additional Info")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            Spacer()
            // Кнопка с тремя точками для вызова Bottom Sheet
            Button(action: {
                showBottomSheet = true
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white)
                    .font(.title)
            }
        }
        .padding()
        .bottomSheet(isPresented: $showBottomSheet) {
            bottomSheetContent()
        }
    }
    
    private func bottomSheetContent() -> some View {
        VStack {
            Button(action: {
                // Логика для переименования
                showBottomSheet = false
            }) {
                HStack {
                    Image(systemName: "pencil")
                        .foregroundColor(.yellow)
                    Text("Rename")
                        .foregroundColor(.white)
                }
            }
            .padding()
            
            Button(action: {
                // Логика для добавления в плейлист
                showBottomSheet = false
            }) {
                HStack {
                    Image(systemName: "text.badge.plus")
                        .foregroundColor(.yellow)
                    Text("Add to playlist")
                        .foregroundColor(.white)
                }
            }
            .padding()

            Button(action: {
                onDelete(musicFile)
                showBottomSheet = false
            }) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                    Text("Delete")
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
        .padding(.bottom, 20)
        .background(Color.black.opacity(0.9))
        .cornerRadius(20)
        .frame(maxWidth: .infinity)
    }
}

// Компонент AddPlaylistView поверх HomeView
struct AddPlaylistView: View {
    @Binding var isPresented: Bool
    @State private var playlistName: String = ""
    var onAdd: (String) -> Void
    
    var body: some View {
        VStack {
            Text("Name a playlist")
                .font(.title3)
                .foregroundColor(.white)
                .padding(.bottom, 10)
            
            TextField("Playlist name", text: $playlistName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .background(Color(UIColor.darkGray))
                .cornerRadius(10)
                .foregroundColor(.white)
            
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.systemGray5))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    if !playlistName.isEmpty {
                        onAdd(playlistName)
                        isPresented = false
                    }
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!playlistName.isEmpty ? Color.orange : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(playlistName.isEmpty)
            }
            .padding(.top, 20)
        }
        .padding()
        .background(Color.black.opacity(0.9))
        .cornerRadius(20)
        .frame(width: UIScreen.main.bounds.width - 50, height: 200)
        .shadow(radius: 10)
    }
}

//// Компонент SearchBarView
//struct SearchBarView: View {
//    @Binding var searchText: String
//    
//    var body: some View {
//        HStack {
//            Image(systemName: "magnifyingglass")
//                .foregroundColor(.gray)
//            TextField("Search", text: $searchText)
//                .foregroundColor(.white)
//                .autocapitalization(.none)
//        }
//        .padding(8)
//        .background(Color.gray.opacity(0.2))
//        .cornerRadius(10)
//        .padding(.horizontal)
//    }
//}

// Bottom Sheet модификатор
extension View {
    func bottomSheet<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isPresented.wrappedValue = false
                    }
                
                VStack {
                    Spacer()
                    content()
                }
                .transition(.move(edge: .bottom))
                .animation(.spring())
            }
        }
    }
}

// Компонент PlaylistCell
struct PlaylistCell: View {
    var playlist: PlaylistEntity
    var onTap: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "music.note.list")
                .font(.largeTitle)
                .foregroundColor(.white)
            Text(playlist.name ?? "Unknown")
                .foregroundColor(.white)
                .font(.caption)
                .lineLimit(1)
        }
        .frame(width: 100, height: 100)
        .background(Color.green)
        .cornerRadius(10)
        .onTapGesture {
            onTap()
        }
    }
}
