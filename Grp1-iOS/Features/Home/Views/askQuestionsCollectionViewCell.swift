//
//  askQuestionsCollectionViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class askQuestionsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
            super.awakeFromNib()

            contentView.backgroundColor = UIColor.systemBackground
            contentView.layer.cornerRadius = 20
            contentView.layer.masksToBounds = true
            questionLabel.numberOfLines = 0

            answerLabel.numberOfLines = 0

        }

        func configureCell(with qa: ArticleQA) {
            questionLabel.text = qa.question
            answerLabel.text = qa.answer

            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            timeLabel.text = formatter.string(from: qa.createdAt)
        }

}
