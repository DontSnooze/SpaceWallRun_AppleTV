//
//  GameConstants.swift
//  SpaceWallRunATV
//
//  Created by Amos Todman on 3/4/19.
//  Copyright © 2019 Amos Todman. All rights reserved.
//

import Foundation

// timer keys
let locationTimerKey = "LocationTimerKey"
let brickBarrierLocationTimerKey = "BrickBarrierLocationTimerKey"
let wallTimerKey = "WallTimerKey"
let hudTimerKey = "HudTimerKey"
let defaultJoystickSensitivity = 5
let backGroundNotificationKey = NSNotification.Name("BackGroundNotificationKey")
// lives
enum GameLives: Int {
    case superEasy = 100000000
    case easy = 10
    case hard = 5
    case survival = 0
}

enum GameDifficulty {
    case superEasy
    case easy
    case hard
    case survival
}

func livesForGameDifficulty(difficulty: GameDifficulty) -> GameLives {
    switch difficulty {
    case .superEasy:
        return .superEasy
    case .easy:
        return .easy
    case .hard:
        return .hard
    case .survival:
        return .survival
    }
}

// brick points
enum BrickPoint: Int {
    case level1 = 1
    case level2 = 5
    case level3 = 10
}

enum UnbreakableWallPoint: Int {
    case level1 = 20
    case level2 = 100
    case level3 = 200
}

// brick points
enum GameLevel: Int {
    case one
    case two
    case three
}

func brickPoint(for level: GameLevel) -> Int {
    switch level {
    case .one:
        return BrickPoint.level1.rawValue
    case .two:
        return BrickPoint.level2.rawValue
    case .three:
        return BrickPoint.level3.rawValue
    }
}

func unbreakableWallPoint(for level: GameLevel) -> Int {
    switch level {
    case .one:
        return UnbreakableWallPoint.level1.rawValue
    case .two:
        return UnbreakableWallPoint.level2.rawValue
    case .three:
        return UnbreakableWallPoint.level3.rawValue
    }
}
