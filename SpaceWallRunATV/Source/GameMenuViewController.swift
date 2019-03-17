//
//  GameMenuViewController.swift
//  SpaceWallRunATV
//
//  Created by Amos Todman on 3/17/19.
//  Copyright © 2019 Amos Todman. All rights reserved.
//

import UIKit
import SceneKit

@objc protocol GameMenuViewControllerDelegate: AnyObject {
    func newGamePressedInGameMenu()
    func continuePressedInGameMenu()
    func restartPressedInGameMenu()
    func settingsPressedInGameMenu()
    func joystickSensitivityPressedInGameMenu()
    func joystickSensitivitySelectedInGameMenu()
}

class GameMenuViewController: UIViewController {
    
    weak var delegate:GameMenuViewControllerDelegate?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var titleLabel: UILabel?
    var tableArray = [String]()
    var game = GameHelper.sharedInstance
    
    // MARK: - UIViewController -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 106.0
        setupMenuTableArray()
        self.view.layer.borderWidth = 1.0
        self.view.layer.borderColor = UIColor.white.cgColor
        self.view.layer.cornerRadius = 5.0
        
    }
    
    func gameView() -> GameViewController? {
        guard let parent = self.parent as? GameViewController else {
            return nil
        }
        return parent
    }
    
    func setupTitle() {
        let title = game.state == .GameOver ? "Game Over" : "Space Wall Run"
        var lastScore = 0
        if let score = gameView()?.lastScore {
            lastScore = score
        }
        let message = game.state == .GameOver ? "Score: 💥\(lastScore)\nHigh Score: 😎\(game.highScore)" : nil
        
        titleLabel?.text = title
        
    }
    // MARK: - TableView Setup
    
    func setupTable(for menuType: GameMenuType) {
        setupTitle()
        switch menuType {
        case .main:
            setupMenuTableArray()
        case .settings:
            setupTableArrayForSettings()
        case .joystickSensitivity:
            setupTableArrayForJoystickSensitivity()
        default:
            break
        }
    }
    
    func setupMenuTableArray() {
        gameView()?.controllerUserInteractionEnabled = true
        gameView()?.gameMenuType = .main
        tableArray = [String]()
        
        let continueTitle = game.state == .Playing ? "Continue" : "New Game"
        
        tableArray.append(continueTitle)
        
        if game.state == .Playing {
            tableArray.append("Restart")
        }
        
        tableArray.append("Settings")
        
        tableView?.reloadData()
    }
    
    func setupTableArrayForSettings() {
        gameView()?.controllerUserInteractionEnabled = false
        gameView()?.gameMenuType = .settings
        tableArray = [String]()
        tableArray.append("Joystick Sensitivity")
        
        tableView?.reloadData()
        tableView?.setContentOffset(.zero, animated: true)
    }
    
    func setupTableArrayForJoystickSensitivity() {
        gameView()?.controllerUserInteractionEnabled = false
        gameView()?.gameMenuType = .joystickSensitivity
        tableArray = [String]()
        for i in 1..<11 {
            tableArray.append("\(i)")
        }
        
        tableView?.reloadData()
    }
    
    // MARK: - Focus Engine
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        if let previousCell = context.previouslyFocusedItem as? GameMenuTableViewCell {
            previousCell.menuButton?.isHighlighted = false
        }
        
        if let nextCell = context.nextFocusedItem as? GameMenuTableViewCell {
            nextCell.menuButton?.isHighlighted = true
        }
    }
}

extension GameMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "GameMenuTableViewCell"
        
        guard let cell:GameMenuTableViewCell = self.tableView?.dequeueReusableCell(withIdentifier: cellId) as? GameMenuTableViewCell else {
            return UITableViewCell()
        }
        
        cell.menuLabel?.text = self.tableArray[indexPath.row]
        cell.menuButton?.setTitle(self.tableArray[indexPath.row], for: .normal)
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(#function)")
        
        guard let gameView = gameView() else {
            return
        }
        
        switch gameView.gameMenuType {
        case .main:
            handleMainMenuButtonPressed(at: indexPath.row)
        case .settings:
            handleMenuSettingsButtonPressed(at: indexPath.row)
        case .joystickSensitivity:
            handleJoystickSensitivityButtonPressed(at: indexPath.row)
        default:
            break
        }
    }
    
    func handleMainMenuButtonPressed(at index: Int) {
        let buttonString = tableArray[index]
        guard let gameView = gameView() else {
            print("\(#function) gameView was nil")
            return
        }
        
        switch buttonString {
        case "Continue":
            self.view.isHidden = true
            gameView.continuePressed()
            gameView.gameMenuType = .none
            delegate?.continuePressedInGameMenu()
        case "New Game":
            self.view.isHidden = true
            gameView.newGamePressed()
            gameView.gameMenuType = .none
            delegate?.newGamePressedInGameMenu()
        case "Restart":
            self.view.isHidden = true
            gameView.restartPressed()
            gameView.gameMenuType = .none
            delegate?.restartPressedInGameMenu()
        case "Settings":
            gameView.gameMenuType = .settings
            setupTableArrayForSettings()
            delegate?.settingsPressedInGameMenu()
        default:
            break
        }
    }
    
    func handleMenuSettingsButtonPressed(at index: Int) {
        let buttonString = tableArray[index]
        guard let gameView = gameView() else {
            print("\(#function) gameView was nil")
            return
        }
        
        switch buttonString {
        case "Joystick Sensitivity":
            delegate?.joystickSensitivityPressedInGameMenu()
            gameView.gameMenuType = .joystickSensitivity
            setupTableArrayForJoystickSensitivity()
        default:
            break
        }
    }
    
    func handleJoystickSensitivityButtonPressed(at index: Int) {
        let buttonString = tableArray[index]
        
        guard let gameView = gameView() else {
            print("\(#function) gameView was nil")
            return
        }
        
        switch buttonString {
        case "1":
            gameView.joystickSensitivity = 10
        case "2":
            gameView.joystickSensitivity = 9
        case "3":
            gameView.joystickSensitivity = 8
        case "4":
            gameView.joystickSensitivity = 7
        case "5":
            gameView.joystickSensitivity = 6
        case "6":
            gameView.joystickSensitivity = 5
        case "7":
            gameView.joystickSensitivity = 4
        case "8":
            gameView.joystickSensitivity = 3
        case "9":
            gameView.joystickSensitivity = 2
        case "10":
            gameView.joystickSensitivity = 1
        default:
            break
        }
        
        gameView.gameMenuType = .settings
        delegate?.joystickSensitivitySelectedInGameMenu()
        setupTableArrayForSettings()
    }
}
