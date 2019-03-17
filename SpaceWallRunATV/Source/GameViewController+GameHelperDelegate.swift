//
//  GameViewController+GameHelperDelegate.swift
//  SpaceWallRunATV
//
//  Created by Amos Todman on 3/9/19.
//  Copyright © 2019 Amos Todman. All rights reserved.
//

import Foundation

extension GameViewController: GameHelperDelegate {    
    func gameHelperWillResetGame(with lastScore: Int) {
        self.lastScore = lastScore
        handleGameOver()
    }
    
    func handleGameOver() {
        stopWalls()
        game.state = .GameOver
        if !scnScene.isPaused {
            playPauseButtonPressed()
        }
    }
}

