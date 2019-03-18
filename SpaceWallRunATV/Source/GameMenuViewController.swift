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
        self.view.layer.cornerRadius = 10.0
     
        tableView?.remembersLastFocusedIndexPath = false
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
        
        var displayString = title
        
        if game.state == .GameOver {
            displayString = "\(title)\nScore: 💥\(lastScore)\nHigh Score: 😎\(game.highScore)"
        }
        titleLabel?.text = displayString
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
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        guard let tableView = tableView else {
            return [UIFocusEnvironment]()
        }
        
        return [tableView]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "GameMenuTableViewCell"
        
        guard let cell:GameMenuTableViewCell = self.tableView?.dequeueReusableCell(withIdentifier: cellId) as? GameMenuTableViewCell else {
            return UITableViewCell()
        }
        
        cell.menuButton?.setTitle(self.tableArray[indexPath.row], for: .normal)
        cell.menuButton?.isSelected = false
        
        if
            let gameView = gameView(),
            gameView.gameMenuType == .joystickSensitivity,
            GameMenuViewController.joystickSensitivityForUserInput(self.tableArray[indexPath.row]) == gameView.joystickSensitivity
        {
            cell.menuButton?.isSelected = true
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("\(#function)")
        
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
    
    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        guard
            let gameView = gameView(),
            gameView.gameMenuType == .joystickSensitivity
        else {
//            print("\(#function) not on joystickSensitivity menu or gameView was nil")
            return IndexPath(row: 0, section: 0)
        }
        
        let currentSelectionIndex = rowForJoystickSensitivity(sensitivity: gameView.joystickSensitivity)
        let indexPath = IndexPath(row: currentSelectionIndex, section: 0)
        return indexPath
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
    
    class func joystickSensitivityForUserInput(_ userInputString: String) -> Int {
        var result = 0
        switch userInputString {
        case "1":
            result = 10
        case "2":
            result = 9
        case "3":
            result = 8
        case "4":
            result = 7
        case "5":
            result = 6
        case "6":
            result = 5
        case "7":
            result = 4
        case "8":
            result = 3
        case "9":
            result = 2
        case "10":
            result = 1
        default:
            break
        }
        return result
    }
    
    func rowForJoystickSensitivity(sensitivity: Int) -> Int {
        var result = 0
        switch sensitivity {
        case 10:
            result = 0
        case 9:
            result = 1
        case 8:
            result = 2
        case 7:
            result = 3
        case 6:
            result = 4
        case 5:
            result = 5
        case 4:
            result = 6
        case 3:
            result = 7
        case 2:
            result = 8
        case 1:
            result = 9
        default:
            break
        }
        return result
    }
}
