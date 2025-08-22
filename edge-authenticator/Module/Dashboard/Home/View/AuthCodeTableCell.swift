//

import UIKit

protocol AuthCodeTableCellDelegate: AnyObject {
    func authCodeTableCell(_ cell: AuthCodeTableCell, didTapEditButtonFor indexPath: IndexPath)
    func authCodeTableCell(_ cell: AuthCodeTableCell, didTapDeleteButtonFor indexPath: IndexPath)
}

class AuthCodeTableCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var delegate: AuthCodeTableCellDelegate?
    var indexPath = IndexPath(row: 0, section: 0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        editButton.addTarget(self, action: #selector(self.onTappedEditButton), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(self.onTappedDeleteButton), for: .touchUpInside)
    }

    func config(_ displayModel: DisplayModel, indexPath: IndexPath) {
        self.indexPath = indexPath
        
        titleLabel.text = displayModel.title
        
        codeLabel.text = displayModel.code
        codeLabel.textColor = displayModel.color
        
        progressView.trackColor = displayModel.color
        progressView.setProgress(
            displayModel.progress,
            animated: true
        )
    }
    
    @objc func onTappedEditButton() {
        delegate?.authCodeTableCell(self, didTapEditButtonFor: indexPath)
    }
    
    @objc func onTappedDeleteButton() {
        delegate?.authCodeTableCell(self, didTapDeleteButtonFor: indexPath)
    }
}
// MARK: - Display Model
extension AuthCodeTableCell {
    
    struct DisplayModel {
        var title: String
        var code: String
        var progress: CGFloat
        var color: UIColor
    }
}
