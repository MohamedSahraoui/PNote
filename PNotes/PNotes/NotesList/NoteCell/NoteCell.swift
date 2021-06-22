//
//  Copyright © 2021 Mac SE. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {

    @IBOutlet private weak var noteTitle: UILabel!
    
    func configure(title: String) {
        noteTitle.text = title
    }
}
