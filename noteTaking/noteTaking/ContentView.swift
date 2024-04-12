//
//  ContentView.swift
//  noteTaking
//
//  Created by StudentAM on 3/25/24.
//

import SwiftUI

struct ContentView: View {
    // State variables to manage the presentation of new note view and the array of notes
    @State private var showingNewNoteView = false
    @State private var notes: [Note] = []

    var body: some View {
        NavigationView {
            VStack {
                // Header section
                HStack {
                    Text("Notes") // Title text
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()

                // List of notes
                List {
                    ForEach(notes.indices, id: \.self) { index in
                        NavigationLink(destination: DetailNoteView(note: $notes[index], notes: $notes)) {
                            Text(notes[index].title) // Display note title
                        }
                    }
                    .onDelete(perform: deleteNote) // Allow deleting notes
                }
                
                Spacer()

                // Add Task button
                Button("Add Task") {
                    showingNewNoteView = true // Show new note view when tapped
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .font(.system(size: 28)) // Button text size
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top, 20) // Add padding to move the button down
                .padding()
                .background(Color.blue) // Button background color
            }
            .navigationBarHidden(true) // Hide navigation bar
        }
        .sheet(isPresented: $showingNewNoteView) {
            // New note view presented as a sheet
            NewNoteView { title, text in
                let newNote = Note(id: UUID(), title: title, text: text)
                notes.append(newNote) // Add new note to the array
                showingNewNoteView = false // Dismiss the new note view
            }
        }
    }

    // Function to delete a note at specified offsets
    private func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }
}

// New note view
struct NewNoteView: View {
    @State private var noteTitle = ""
    @State private var noteText = ""
    var addNoteAction: (String, String) -> Void
    
    // Check if the note fields are empty
    private var isNoteEmpty: Bool {
        return noteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack {
            // New note view UI components
            Text("New Note")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding()

            TextField("Title", text: $noteTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextEditor(text: $noteText)
                .border(Color.gray, width: 1)
                .cornerRadius(8)
                .padding()

            Button("Add Note") {
                addNoteAction(noteTitle, noteText) // Perform action to add new note
            }
            .disabled(isNoteEmpty) // Disable button if note fields are empty
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.bottom)
        }
        .padding()
    }
}

// Note structure to represent individual notes
struct Note: Identifiable {
    var id: UUID
    var title: String
    var text: String
}

// Detail view for a specific note
struct DetailNoteView: View {
    @State private var editedTitle: String
    @State private var editedText: String
    @Binding var note: Note
    @Binding var notes: [Note]
    @Environment(\.presentationMode) var presentationMode

    // Initialize detail view with a note and notes array
    init(note: Binding<Note>, notes: Binding<[Note]>) {
        self._note = note
        self._notes = notes
        self._editedTitle = State(initialValue: note.wrappedValue.title)
        self._editedText = State(initialValue: note.wrappedValue.text)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Text field to edit note title
            TextField("Title", text: $editedTitle)
                .font(.title)
                .bold()

            // Text editor to edit note text
            TextEditor(text: $editedText)
                .font(.body)

            Spacer()
        }
        .padding()
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: HStack {
            Button("Delete") {
                deleteNote() // Delete the current note
            }
            Button("Save") {
                saveNote() // Save changes to the current note
            }
        })
    }

    // Function to delete the current note
    private func deleteNote() {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes.remove(at: index)
            presentationMode.wrappedValue.dismiss()
        }
    }

    // Function to save changes to the current note
    private func saveNote() {
        note.title = editedTitle
        note.text = editedText
        presentationMode.wrappedValue.dismiss()
    }
}


#Preview {
    ContentView()
}
