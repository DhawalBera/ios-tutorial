//
//  TabInfoSettingsController.swift
//  TabDemo
//
//  Created by guest2 on 08/09/2020.
//  Copyright © 2020 yocto. All rights reserved.
//

import UIKit

class TabInfoSettingsController: UIViewController, TabInfoable {
    private static let tabInfoSettingsItemCellClassName = String(describing: TabInfoSettingsItemCell.self)
    private static let tabInfoSettingsFooterCellClassName = String(describing: TabInfoSettingsFooterCell.self)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var tabInfo: TabInfo?
       
    var viewController: ViewController? {
        if let parent = self.parent?.parent as? ViewController {
            return parent
        }
        return nil
    }
    
    var filteredTabInfos: [TabInfo]? {
        return self.viewController?.tabInfos.filter({ $0.type != TabInfoType.Settings })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = layoutConfig()
        
        collectionView.register(
            UINib(nibName: TabInfoSettingsController.tabInfoSettingsItemCellClassName, bundle: nil),
            forCellWithReuseIdentifier: TabInfoSettingsController.tabInfoSettingsItemCellClassName
        )
        
        collectionView.register(
            UINib(nibName: TabInfoSettingsController.tabInfoSettingsFooterCellClassName, bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: TabInfoSettingsController.tabInfoSettingsFooterCellClassName
        )
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let gesture = UILongPressGestureRecognizer(target:self, action: #selector(longPressGesture))
        // Mimic short tap. But this blocks the events for delete button and text field :-(
        gesture.minimumPressDuration = 0
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc func longPressGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case UIGestureRecognizerState.began:
            self.began(gesture)
        case UIGestureRecognizerState.changed:
            self.changed(gesture)
        case UIGestureRecognizerState.ended:
            self.end(gesture)
        default:
            self.cancel(gesture)
        }
    }
    
    private func layoutConfig() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        return UICollectionViewCompositionalLayout (sectionProvider: { (sectionNumber, env) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(CGFloat(Constants.TAB_INFO_SETTINGS_CELL_HEIGHT))
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(CGFloat(Constants.TAB_INFO_SETTINGS_CELL_HEIGHT))
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 0
            
            let footerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(CGFloat(Constants.TAB_INFO_SETTINGS_CELL_HEIGHT))
            )
            let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
            section.boundarySupplementaryItems = [sectionFooter]
            
            return section
        }, configuration: configuration)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TabInfoSettingsController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTabInfos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let tabInfoSettingsItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: TabInfoSettingsController.tabInfoSettingsItemCellClassName, for: indexPath) as? TabInfoSettingsItemCell {
            tabInfoSettingsItemCell.delegate = self
            tabInfoSettingsItemCell.reorderDelegate = self
            tabInfoSettingsItemCell.textField.text = filteredTabInfos?[indexPath.row].getPageTitle()
            return tabInfoSettingsItemCell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TabInfoSettingsController.tabInfoSettingsFooterCellClassName, for: indexPath)
            return footerView

        default:
            fatalError()
        }
    }
}

extension TabInfoSettingsController: TabInfoSettingsItemCellDelegate {
    func crossButtonClick(_ sender: UIButton) {
        print("crossButtonClick happens")
        
        let hitPoint = (sender as AnyObject).convert(CGPoint.zero, to: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: hitPoint) {
            // use indexPath to get needed data
            print("crossButtonClick row is -> \(indexPath.row)")
            
            viewController?.deleteTabInfo(indexPath)
            
            self.collectionView.deleteItems(at: [indexPath])
        }
    }
}

extension TabInfoSettingsController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("moveItemAt sourceIndexPath -> \(sourceIndexPath)")
        print("moveItemAt destinationIndexPath -> \(destinationIndexPath)")
        
        viewController?.moveTabInfo(at: sourceIndexPath, to: destinationIndexPath)

        // ??? Doesn't work. Force to use reloadData
        //self.collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
        //self.collectionView.reloadItems(at: [sourceIndexPath, destinationIndexPath])
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        print("canMoveItemAt!")
        return true
    }
}

extension TabInfoSettingsController: ReorderDelegate {
    func began(_ gesture: UILongPressGestureRecognizer) {
        print("==began==")
        
        guard let selectedIndexPath = self.collectionView?.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
            return
        }
        
        let flag = collectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
        
        print("==began== selectedIndexPath -> \(selectedIndexPath), flag -> \(flag)")
    }
    
    func changed(_ gesture: UILongPressGestureRecognizer) {
        print("==changed==")
        collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
    }
    
    func end(_ gesture: UILongPressGestureRecognizer) {
        print("==end==")
        collectionView?.endInteractiveMovement()
    }
    
    func cancel(_ gesture: UILongPressGestureRecognizer) {
        print("==cancel==")
        collectionView?.cancelInteractiveMovement()
    }
}
