//
//  Home.swift
//  Halo2
//
//  Created by Team 23 Halo on 2/23/23.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        let titleLabel=UILabel()
        titleLabel.text="Halo"
        titleLabel.font=UIFont.systemFont(ofSize: 24)
        titleLabel.textColor = .black
        view.addSubview(titleLabel)
        
        let button1=UIButton()
        button1.setTitle("Connect", for: .normal)
        button1.backgroundColor = .blue
        view.addSubview(button1)
        
        let button2=UIButton()
        button2.setTitle("How to Use", for: .normal)
        button2.backgroundColor = .red
        view.addSubview(button2)
        
        let button3=UIButton()
        button3.setTitle("Website", for: .normal)
        button3.backgroundColor = .green
        view.addSubview(button3)
        
        //Auto Layout Constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        button1.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([
            button1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            button1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button1.widthAnchor.constraint(equalToConstant: 200),
            button1.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        button2.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([
            button2.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            button2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button2.widthAnchor.constraint(equalToConstant: 200),
            button2.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        button3.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([
            button3.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            button3.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button3.widthAnchor.constraint(equalToConstant: 200),
            button3.heightAnchor.constraint(equalToConstant: 50)
        ])
        
    }
}
