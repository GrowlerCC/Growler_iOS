//
// Created by Alexander Gorbovets on 2017-02-25.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var keywordField: UITextField!

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var tags: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keywordField.layer.cornerRadius = 16.5
        keywordField.layer.borderColor = Colors.grayControlBorderColor.cgColor
        keywordField.layer.borderWidth = 1

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
        cell.tagName = tag
        cell.button.setTitle(tag, for: .normal)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 40)
    }

}
