//
//  ViewController.swift
//  MySounds
//
//  Created by Jon Vogel on 1/31/17.
//  Copyright © 2017 Jon Vogel. All rights reserved.
//

import UIKit
import JVFlowerMenu

class ViewController: UIViewController {
    //MARK: Properties
    
    
    let menu = JVFlowerMenu(withImage: nil, andTitle: nil)
    
    //MARK: Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.menu.translatesAutoresizingMaskIntoConstraints = false
        self.menu.delegate = self
        self.menu.startAngle = 100
        self.view.addSubview(self.menu)
        self.menu.addPedal(withImage: UIImage(named: "Settings"), withTitle: "Settings")
        self.menu.addPedal(withImage: UIImage(named: "Mic"), withTitle: "Record")
        self.constrainMenu()
        self.flowerMenuDidSelectPedalWithID(self.menu, pedal: self.menu.pedals[1])
        self.menu.isHidden = true
    }


    
    //MARK: Constrain menu
    
    func constrainMenu() {
        var constraints = [NSLayoutConstraint]()
        
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[menu]", options: [], metrics: nil, views: ["menu": self.menu])
        constraints.append(contentsOf: horizontal)
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[menu]", options: [], metrics: nil, views: ["menu": self.menu])
        constraints.append(contentsOf: vertical)
        
        self.view.addConstraints(constraints)
        
    }
    
    //MARK: Container Management
    
    func addContent(_ content: UIViewController) {
        guard let menuIndex = self.view.subviews.index(of: self.menu) else {
            return
        }
        
        self.addChildViewController(content)
        content.view.frame = self.view.frame
        self.view.insertSubview(content.view, at: menuIndex - 1)
        content.didMove(toParentViewController: self)
    }
    
    func removeContent(_ content: UIViewController) {
        
    }

}


extension ViewController: JVFlowerMenuDelegate {
    
    func flowerMenuDidExpand() {
        
        
    }
    
    func flowerMenuDidRetract() {
        
        
    }
    
    func flowerMenuDidSelectPedalWithID(_ theMenu: JVFlowerMenu, pedal: Pedal) {
        
        switch pedal.ID {
        case self.menu.pedals[0].ID:
            print("Implement Settings")
        case self.menu.pedals[1].ID:
            guard let recordVC = self.storyboard?.instantiateViewController(withIdentifier: "RECORDVIEW") as? RecordViewController else {
                return
            }
            
            self.addContent(recordVC)
            
        default:
            return
        }
        
        
    }
    
    
}

