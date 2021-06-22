//
//  Copyright © 2021 Mac SE. All rights reserved.
//

import UIKit

class NotesDetailsViewController: UIViewController {

    @IBOutlet private weak var noteTitleLabel: UILabel!
    @IBOutlet private weak var noteDescriptionLabel: UILabel!
    var note: NoteModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTitleLabel.text = note.noteTitle
        noteDescriptionLabel.text = note.noteDescription
    }
}
