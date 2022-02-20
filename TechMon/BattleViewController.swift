//
//  BattleViewController.swift
//  TechMon
//
//  Created by Motonari Sakuma on 2022/02/20.
//

import UIKit
import AVFoundation

class BattleViewController: UIViewController {
    //プレイヤーの関連付けするパーツ
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var playerHPLabel: UILabel!
    @IBOutlet var playerMPLabel: UILabel!
    @IBOutlet var playerTPLabel: UILabel!
    
    //的の関連付けするパーツ
    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var enemyImageView: UIImageView!
    @IBOutlet var enemyHPLabel: UILabel!
    @IBOutlet var enemyMPLabel: UILabel!
    //音楽再生などで使う便利クラス
    let techMonManager = TechMonManager.shared //音楽再生などで使う便利クラス
    
    //キャラクターのステータス
//    var playerHP = 100
//    var playerMP = 0
//    var enemyHP = 200
//    var enemyMP = 0
    
    //timer for gaming
    var player: Character!
    var enemy: Character!
    var gameTimer: Timer!
    var isPlayerAttackAvailable: Bool = true //if player can attack

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //キャラクターの読み込み
        player = techMonManager.player
        enemy = techMonManager.enemy
        
        playerNameLabel.text = "勇者"
        playerImageView.image = UIImage(named: "yusya.png")
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
        playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)"
        
        enemyNameLabel.text = "龍"
        enemyImageView.image = UIImage(named: "monster.png")
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxHP)"
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateGame), userInfo: nil, repeats: true)
        gameTimer.fire()
        
        func updateUI() {
            playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
            playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
            
            enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
            enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        techMonManager.playBGM(fileName: "BGM_battle001")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        techMonManager.stopBGM()
    }
    
    @objc func updateGame() {
        player.currentMP += 1
        if player.currentMP >= 20 {
                
                isPlayerAttackAvailable = true
            player.currentMP = 20
            } else {
                isPlayerAttackAvailable = false
            }
            
        enemy.currentMP += 1
        if enemy.currentMP >= 35 {
                enemyAttack()
            enemy.currentMP = 0
            }
            
        playerMPLabel.text = "\(player.currentMP) / 20"
        enemyMPLabel.text = "\(enemy.currentMP) / 35"
        }
        
        func enemyAttack() {
            techMonManager.damageAnimation(imageView: playerImageView)
            techMonManager.playSE(fileName: "SE_attack")
            
            player.currentHP -= 20
            
            playerHPLabel.text = "\(player.currentHP) / 100"
            
            if player.currentHP <= 0 {
                finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
            }
        }
        
        func finishBattle(vanishImageView: UIImageView, isPlayerWin: Bool) {
            techMonManager.vanishAnimation(imageView: vanishImageView)
            techMonManager.stopBGM()
            gameTimer.invalidate()
            isPlayerAttackAvailable = false
            
            var finishMessage: String = ""
            if isPlayerWin {
                techMonManager.playSE(fileName: "SE_fanfare")
                finishMessage = "勇者の勝利"
            } else {
                techMonManager.playSE(fileName: "SE_gameover")
                finishMessage = "勇者の敗北..."
            }
            
            let alert = UIAlertController(title: "バトル終了", message:  finishMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }
        
        @IBAction func attackAction(){
            if isPlayerAttackAvailable {
                
                techMonManager.damageAnimation(imageView: enemyImageView)
                techMonManager.playSE(fileName: "SE_attack")
                
                enemy.currentHP -= player.attackPoint
                
                player.currentHP += 10
                if player.currentTP >= player.maxTP{
                    player.currentTP = player.maxTP
                }
                player.currentMP = 0
                
                judgeButtle()
            }
        }
    
        
    @IBAction func tameruAction() {
        if isPlayerAttackAvailable {
            techMonManager.playSE(fileName: "SE_charge")
            player.currentTP += 40
            if player.currentTP >= player.maxTP {
                
                player.currentTP = player.maxTP
            }
            player.currentMP = 0
        }
    }
        
        @IBAction func fireAction() {
            if isPlayerAttackAvailable && player.currentTP >= 40 {
                techMonManager.damageAnimation(imageView: enemyImageView)
                techMonManager.playSE(fileName: "SE_file")
            
                enemy.currentHP -= 100
            
                player.currentTP -= 40
                if player.currentTP <= 0 {
                    player.currentTP = 0
                }
                player.currentMP = 0
            
                judgeButtle()
        }
    }
    
        func judgeButtle() {
            if player.currentHP <= 0 {
                finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
            } else if enemy.currentHP <= 0 {
                finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
            }
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
