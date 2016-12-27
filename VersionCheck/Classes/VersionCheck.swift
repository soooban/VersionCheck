import UIKit

public class VersionCheck {
    public init() {
        
    }
    
    public static func checkWithFir(apiToken: String, bundleId: String) {
        
        let urlString = "https://api.fir.im/apps/latest/\(bundleId)?api_token=\(apiToken)&type=ios"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            data, response , error in
            if let _ = error {
                return
            }
            
            guard let _ = data else {
                return
            }
            
            guard let localVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
                return
            }
            
            guard let localBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
                return
            }
            
            do {
                let result = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                
                guard let _ = result else {
                    return
                }
                guard let remoteBuild = result!["build"] as? String else {
                    return
                }
                guard let remoteVersion = result!["versionShort"] as? String else {
                    return
                }
                guard let changelog = result!["changelog"] as? String else {
                    return
                }
                guard let updateUrl = result!["update_url"] as? String else {
                    return
                }
                
                if localBuild != remoteBuild || localVersion != remoteVersion {
                    let alertMessage = "最新版本:\(remoteVersion)『\(remoteBuild)』 本地版本:\(localVersion)『\(localBuild)』 更新内容:\(changelog) 是否更新?"
                    let alertController = UIAlertController(title: "提示", message: alertMessage, preferredStyle: .alert)
                    let ensureAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
                        guard let url = URL(string: updateUrl) else {
                            return
                        }
                        UIApplication.shared.openURL(url)
                    })
                    
                    let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                        
                    })
                    alertController.addAction(ensureAction)
                    alertController.addAction(cancelAction)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        guard let rootController = UIApplication.shared.keyWindow?.rootViewController! else {
                            return
                        }
                        
                        rootController.present(alertController, animated: true, completion: nil)
                    }
                }
                
            } catch {
                print("VersionCheck: fir data convert json error")
            }
            
        }).resume()
    }
    
    public static func checkWithFirApiKey(_ key: String) {
        
        guard let bundleId = Bundle.main.bundleIdentifier else {
            return
        }
        checkWithFir(apiToken: key, bundleId: bundleId)
    }
}
