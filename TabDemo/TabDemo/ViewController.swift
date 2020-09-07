//
//  ViewController.swift
//  TabDemo
//
//  Created by guest2 on 03/09/2020.
//  Copyright © 2020 yocto. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tabCollectionView: UICollectionView!
    @IBOutlet weak var tabBottomView: UIView!
    
    private var selectedTabIndex: Int = -1
    
    private var pageViewController: UIPageViewController!
    
    // TODO: String localization.
    private let tabInfos = [
        TabInfo(type: .All, name: nil, colorIndex: 0),
        TabInfo(type: .Calendar, name: nil, colorIndex: 1),
        TabInfo(type: .Custom, name: "Home2", colorIndex: 2),
        TabInfo(type: .Custom, name: "Work3", colorIndex: 3),
        TabInfo(type: .Custom, name: "Work4", colorIndex: 4),
        TabInfo(type: .Custom, name: "Work5", colorIndex: 5),
        TabInfo(type: .Custom, name: "Work6", colorIndex: 6),
        TabInfo(type: .Custom, name: "Work7", colorIndex: 7),
        TabInfo(type: .Custom, name: "Work8", colorIndex: 8),
        TabInfo(type: .Settings, name: nil, colorIndex: 9)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabCollectionView.collectionViewLayout = layoutConfig()
        tabCollectionView.delegate = self
        tabCollectionView.dataSource = self
        
        pageViewController.delegate = self
        pageViewController.dataSource = self  
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // TODO: Testing only.
        selectTab(8)
    }

    // This function is called, when you swipe the page left/right
    private func selectTab(_ index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        self.collectionView(self.tabCollectionView, didSelectItemAt: indexPath)
        
        // TODO: How we can achieve a smoother (with animation) user experience? Please note, if you use "animated: false" in tabCollectionView.selectItem,
        // you will get a weird effect...
        DispatchQueue.main.async {
            self.tabCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            self.tabCollectionView.scrollToItem(at: IndexPath.init(item: self.selectedTabIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let pageController as UIPageViewController:
            self.pageViewController = pageController
            
        default:
            break
        }
    }
    
    private func updateTabBottomView() {
        self.tabBottomView.backgroundColor = tabInfos[selectedTabIndex].getUIColor()
    }
    
    private func layoutConfig() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(44), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(44), heightDimension: .absolute(44))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 1
            section.orthogonalScrollingBehavior = .continuous
            return section
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabInfos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let className = String(describing: TabCollectionViewCell.self)
        
        if let tabCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: className, for: indexPath) as? TabCollectionViewCell {
            let tabInfo = tabInfos[indexPath.row]
            let selected = indexPath.row == self.selectedTabIndex
            tabCollectionViewCell.update(tabInfo, selected)
            return tabCollectionViewCell
        }
        
        return UICollectionViewCell()
    }
    
    // This function will be called either you tap on tab, or you swipe the page left/right.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let oldSelectedTabIndex = self.selectedTabIndex
        self.selectedTabIndex = indexPath.row
        
        self.tabCollectionView.reloadData()
        // TODO: reloadData will reset the scroll position. How can we restore previous scroll position?
        
        updateTabBottomView()
            
        let direction = self.selectedTabIndex > oldSelectedTabIndex ?
            UIPageViewController.NavigationDirection.forward :
            UIPageViewController.NavigationDirection.reverse
        
        // TODO: How can we improve this code?
        if let viewControllers = self.pageViewController.viewControllers {
            if viewControllers.count > 0 {
                if let pageIndexable = viewControllers[0] as? PageIndexable {
                    if pageIndexable.pageIndex != self.selectedTabIndex {
                        self.pageViewController.setViewControllers([viewController(At: self.selectedTabIndex)!], direction: direction, animated: true, completion: nil)
                    }
                }
            } else {
                self.pageViewController.setViewControllers([viewController(At: self.selectedTabIndex)!], direction: direction, animated: true, completion: nil)
            }
        } else {
            self.pageViewController.setViewControllers([viewController(At: self.selectedTabIndex)!], direction: direction, animated: true, completion: nil)
        }
    }
}

extension ViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func viewController(At index: Int) -> UIViewController? {
        
        if((index < 0) || (index >= self.tabInfos.count)) {
            return nil
        }
        
        let className = String(describing: DashboardController.self)
        let dashboardController = storyboard?.instantiateViewController(withIdentifier: className) as! DashboardController
        dashboardController.pageIndex = index
        return dashboardController
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! PageIndexable).pageIndex
        
        if index <= 0 {
            return nil
        }
        
        index -= 1

        return self.viewController(At: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! PageIndexable).pageIndex
        
        if index >= tabInfos.count-1 {
            return nil
        }
        
        index += 1

        return self.viewController(At: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if finished {
            if completed {
                let pageIndexable = pageViewController.viewControllers!.first as! PageIndexable
                selectTab(pageIndexable.pageIndex)
            }
        }
        
    }
}

