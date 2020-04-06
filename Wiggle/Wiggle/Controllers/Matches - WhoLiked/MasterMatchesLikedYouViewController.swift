//
//  MasterMatchesLikedYouViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 6.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit

class MasterMatchesLikedYouViewController: UIViewController {

    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet weak var chatsButton: UIBarButtonItem!
    
    private lazy var matchesViewController: MatchesViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "MatchesViewController") as! MatchesViewController

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()

    private lazy var likedYouViewController: LikedYouViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "LikedYouViewController") as! LikedYouViewController

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    // MARK: - View Methods

    private func setupView() {
        setupSegmentedControl()

        updateView()
    }

    private func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            remove(asChildViewController: likedYouViewController)
            add(asChildViewController: matchesViewController)
        } else {
            remove(asChildViewController: matchesViewController)
            add(asChildViewController: likedYouViewController)
        }
    }

    private func setupSegmentedControl() {
        // Configure Segmented Control
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "Matches", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Liked You", at: 1, animated: false)
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)

        // Select First Segment
        segmentedControl.selectedSegmentIndex = 0
    }

    // MARK: - Actions

    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }

    // MARK: - Helper Methods

    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        view.addSubview(viewController.view)

        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)

        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParent()
    }
    @IBAction func backToChats(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
