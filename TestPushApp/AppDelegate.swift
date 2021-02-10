//
//  AppDelegate.swift
//  TestPushApp
//
//  Created by Akihiro Matsuyama on 2020/08/17.
//  Copyright © 2020 Akihiro Matsuyama. All rights reserved.
//

import UIKit
import UserNotifications
import NCMB

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    //********** APIキーの設定 **********
    let applicationkey = "519b40a0e078743fdc597b60d1ff693c68a953a6741c153833362febc9b7e178"
    let clientkey      = "7875655c01446019c213ded7ecefff223b97d4359ba228f22a5dfa15fa03d24f"



// MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //********** SDKの初期化 **********
        NCMB.setApplicationKey(applicationkey, clientKey: clientkey)
//        NCMB.initialize(applicationKey: applicationkey, clientKey: clientkey)
        //▼▼▼起動時に処理される▼▼▼
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) {granted, error in
            if error != nil {
                // エラー時の処理
                return
            }
            if granted {
                // デバイストークンの要求
                UIApplication.shared.registerForRemoteNotifications()
            }
        }

//        //********** データストアにデータを保存 **********
//        let obj = NCMBObject(className: "TestClass")
//        obj?.setObject("Hello, NCMB!", forKey: "message")
//        obj?.saveInBackground({ (error) in
//            if error != nil {
//                // 保存に失敗した場合の処理
//            }else{
//                // 保存に成功した場合の処理
//            }
//        })
//
//        // デバイストークンの要求
//        if #available(iOS 10.0, *){
//            /** iOS10以上 **/
//            let center = UNUserNotificationCenter.current()
//            center.requestAuthorization(options: [.alert, .badge, .sound]) {granted, error in
//                if error != nil {
//                    // エラー時の処理
//                    return
//                }
//                if granted {
//                    DispatchQueue.main.async(execute: {
//                      UIApplication.shared.registerForRemoteNotifications()
//                    })
//                }
//            }
//        } else {
//            /** iOS8以上iOS10未満 **/
//            //通知のタイプを設定したsettingを用意
//            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            //通知のタイプを設定
//            application.registerUserNotificationSettings(setting)
//            //DevoceTokenを要求
//            UIApplication.shared.registerForRemoteNotifications()
//        }
        //▲▲▲起動時に処理される▲▲▲
        return true
    }

    // デバイストークンが取得されたら呼び出されるメソッド
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){


        // 端末情報を扱うNCMBInstallationのインスタンスを作成
        let installation = NCMBInstallation.current()
        // デバイストークンの設定
        installation?.setDeviceTokenFrom(deviceToken)
        // 端末情報をデータストアに登録
        installation?.saveInBackground({ (error) in
            if error != nil {
                // 端末情報の登録に失敗した時の処理
                let err = error! as NSError
                print("端末情報の登録に失敗")
                if (err.code == 409001){

                    // 失敗した原因がデバイストークンの重複だった場合
                    // 端末情報を上書き保存する
//                    self.updateExistInstallation(currentInstallation: installation!)
                }else{

                    // デバイストークンの重複以外のエラーが返ってきた場合
                }
            } else {
                print("端末情報の登録に成功")
                // 端末情報の登録に成功した時の処理
            }
        })
    }

    // 端末情報を上書き保存するupdateExistInstallationメソッドを用意
    func updateExistInstallation(currentInstallation : NCMBInstallation){
        let installationQuery = NCMBInstallation.query()
        installationQuery?.whereKey("deviceToken", equalTo:currentInstallation.deviceToken)
        do {
            let searchDevice = try installationQuery?.getFirstObject() as! NCMBInstallation
            // 端末情報の検索に成功した場合
            // 上書き保存する
            currentInstallation.objectId = searchDevice.objectId
            currentInstallation.saveInBackground({ (error) in
                if (error != nil){
                    // 端末情報の登録に失敗した時の処理
                }else{
                    // 端末情報の登録に成功した時の処理
                }
            })
        } catch let searchErr as NSError {
            // 端末情報の検索に失敗した場合の処理
        }
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

