//
// Created by Alexander Gorbovets on 2017-02-25.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    @IBOutlet weak var keywordField: UITextField!

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var tags: [String] = []

    public var selectedTags = Set<String>()

    override func viewDidLoad() {
        super.viewDidLoad()
        keywordField.layer.cornerRadius = 16.5
        keywordField.layer.borderColor = Colors.grayControlBorderColor.cgColor
        keywordField.layer.borderWidth = 1
        keywordField.delegate = self

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "SearchTagCell", bundle: nil), forCellWithReuseIdentifier: "SearchTagCell")
        
        getTags(page: 1).then {
            tags -> Void in
            self.tags = tags
            mq { self.collectionView.reloadData() }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keywordField.becomeFirstResponder()
    }

    @IBAction func didTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchTagCell", for: indexPath) as! SearchTagCell
        let tag = tags[indexPath.row]
        cell.searchViewController = self
        cell.tagName = tag
        cell.button.setTitle(tag, for: .normal)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tag = tags[indexPath.row]
        let font = UIFont(name: "Lato", size: 15)!
        let textWidth = tag.boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity),
            options: .usesLineFragmentOrigin,
            attributes: [NSFontAttributeName: font],
            context: nil
        ).size.width
        let cornerRadius = CGFloat(16.5)
        return CGSize(width: textWidth + cornerRadius * 2, height: cornerRadius * 2)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keywordField.resignFirstResponder()
        let controller = ProductListViewController(client: ShopifyController.instance.client, collection: nil)!
        controller.searchKeyword = keywordField.text
        controller.tags = Array<String>(selectedTags)
        dismiss(animated: false)
        if let navigation = AppDelegate.shared.navigationController {
            navigation.delegate?.navigationController?(navigation, willShow: controller, animated: false) // navigation controller doesn't fir it when viewControllers are assigned
            navigation.viewControllers = [controller]
        }
        return true
    }

}
