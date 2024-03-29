//
//  ARContainerViewController.swift
//  demo
//
//  Created by Maksim on 10/10/18.
//  Copyright © 2018 Mapbox. All rights reserved.
//

import UIKit
import MapboxVisionAR
import MapboxDirections
import MapboxCoreNavigation
import CoreMedia

private let inset: CGFloat = 18.0

final class ARContainerViewController: UIViewController {

    private lazy var mapViewController = ARMapNavigationController()
    private lazy var arViewController = VisionARViewController()
    
    weak var navigationDelegate: NavigationManagerDelegate? {
        didSet {
            arViewController.navigationDelegate = navigationDelegate
        }
    }
    
    override func viewDidLoad() {
        mapViewController.completion = present

        presentMap()
        
        arViewController.view.addSubview(endButton)
        NSLayoutConstraint.activate([
            endButton.trailingAnchor.constraint(equalTo: arViewController.view.trailingAnchor, constant: -inset),
            endButton.topAnchor.constraint(equalTo: arViewController.view.safeAreaLayoutGuide.topAnchor, constant: inset),
            endButton.heightAnchor.constraint(equalToConstant: 44),
            endButton.widthAnchor.constraint(equalToConstant: 90),
        ])
        
        arViewController.view.addSubview(instructionsLabel)
        NSLayoutConstraint.activate([
            instructionsLabel.centerXAnchor.constraint(equalTo: arViewController.view.safeAreaLayoutGuide.centerXAnchor),
            instructionsLabel.topAnchor.constraint(equalTo: arViewController.view.safeAreaLayoutGuide.topAnchor, constant: inset),
            instructionsLabel.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc func presentMap() {
        dismiss(viewController: arViewController)
        present(viewController: mapViewController)
    }
    
    func present(route: MapboxDirections.Route) {
        dismiss(viewController: mapViewController)
        
        let navigationService = MapboxNavigationService(route: route)
        arViewController.navigationService = navigationService
        arViewController.navigationService?.delegate = self
        present(viewController: arViewController)
    }
    
    func present(sampleBuffer: CMSampleBuffer) {
        arViewController.present(sampleBuffer: sampleBuffer)
    }
    
    func present(lane: ARLane?) {
        arViewController.present(lane: lane)
    }
    
    func present(camera: ARCamera) {
        arViewController.present(camera: camera)
    }
    
    private let instructionsLabel: UILabel = {
        let label = PaddedLabel(insets: UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor(white: 0, alpha: 0.85)
        label.textColor = .white
        label.font = UIFont(name: "AvenirNext-Medium", size: 18)
        label.layer.cornerRadius = 22
        label.isHidden = true
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private let endButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("End", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.red, for: .normal)
        button.setBackgroundColor(UIColor(white: 0, alpha: 0.85), for: .normal)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(presentMap), for: .touchUpInside)
        return button
    }()
}

extension ARContainerViewController: NavigationServiceDelegate {
    
    func navigationService(_ service: NavigationService, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        instructionsLabel.isHidden = false
        instructionsLabel.text = progress.currentLegProgress.currentStep.instructions
    }
}
