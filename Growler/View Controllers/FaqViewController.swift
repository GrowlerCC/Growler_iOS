//
// Created by Jeff H. on 2017-02-24.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit
import EMString

class FaqViewController: UIViewController {

    @IBOutlet weak var faqText: UILabel!

    static var registeredStyles = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if !FaqViewController.registeredStyles {
            FaqViewController.registeredStyles = true
            let questionStyle = EMStylingClass(markup: "<growler_question>")!
            questionStyle.color = Colors.launchScreenOrangeColor
            questionStyle.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold)
            EMStringStylingConfiguration.sharedInstance().addNewStylingClass(questionStyle)

            let answerStyle = EMStylingClass(markup: "<growler_answer>")!
            // important: due to bug in EMString pod app will crash if some EMStylingClass object will have all attributes equal to nil
            answerStyle.color = UIColor.black
            EMStringStylingConfiguration.sharedInstance().addNewStylingClass(answerStyle)
        }

        faqText.attributedText = FAQ
            .map {
                (question: String, answer: String) -> String in
                let line: String = "<growler_question>\(question)</growler_question>\n<growler_answer>\(answer)</growler_answer>\n\n\n"
                return line
            }
            .joined()
            .attributedString
    }

}
