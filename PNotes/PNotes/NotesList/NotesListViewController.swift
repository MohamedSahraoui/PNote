//
//  Copyright © 2021 Mac SE. All rights reserved.
//

import UIKit
import CoreData

class NotesListViewController: UIViewController {

    @IBOutlet private weak var noteTableView: UITableView!
    private let noteCellIdentifier = "noteCellIdentifier"
    var user: User!
    private var notes: [NoteModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier: noteCellIdentifier)
        noteTableView.delegate = self
        noteTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    
    @IBAction func addNoteClick(_ sender: Any) {
        let addNoteVc = AddNoteViewController()
        addNoteVc.addNote = { title, description in
            self.addNote(title: title, description: description)
        }
        navigationController?.pushViewController(addNoteVc, animated: true)
    }
    
    func addNote(title: String, description: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return  }
        let managedContext = appDelegate.persistentContainer.viewContext
        let note = Note(context: managedContext)
        let noteId = Date.timeIntervalSinceReferenceDate
        note.setValue(noteId, forKey: NoteEntity.noteIdKey)
        note.setValue(title, forKey: NoteEntity.noteTitleKey)
        note.setValue(description, forKey: NoteEntity.noteDescriptionKey)
        user.addToNotes(note)
        try? managedContext.save()
    }
    
    private func fetchData() {
        notes.removeAll()
        if let userNotes = user.notes as? Set<Note> {
            for note in userNotes {
                notes.append(.init(
                                id: note.noteId,
                                noteTitle: note.noteTitle ?? "",
                                noteDescription: note.noteDescription ?? "")
                )
            }
        }
        noteTableView.reloadData()
    }
    
    private func removeNote(at indexPath: IndexPath) {
        guard indexPath.row < notes.count,
        let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let noteId = notes[indexPath.row].id
        if let note = noteEntity(noteId: noteId) {
            user.removeFromNotes(note)
            try? managedContext.save()
        }
        fetchData()
        noteTableView.reloadData()
    }
    
    private func noteEntity(noteId: Double) -> Note? {
        if let userNotes = user.notes as? Set<Note> {
            return userNotes.first(where: { $0.noteId == noteId } )
        }
        return nil
    }
}

extension NotesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailsVc = NotesDetailsViewController()
        detailsVc.note = notes[indexPath.row]
        navigationController?.pushViewController(detailsVc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeNote(at: indexPath)
        }
    }
}

extension NotesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: noteCellIdentifier, for: indexPath) as! NoteCell
        cell.configure(title: notes[indexPath.row].noteTitle)
        return cell
    }
}

struct NoteModel {
    let id: Double
    let noteTitle: String
    let noteDescription: String
}
