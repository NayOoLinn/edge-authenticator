//

import UIKit

class AuthCodeTableCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var progressView: CircularProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func config(_ displayModel: DisplayModel) {
        
        titleLabel.text = displayModel.title
        
        codeLabel.text = displayModel.code
        codeLabel.textColor = displayModel.color
        
        progressView.trackColor = displayModel.color
        progressView.setProgress(
            displayModel.progress,
            animated: true
        )
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
