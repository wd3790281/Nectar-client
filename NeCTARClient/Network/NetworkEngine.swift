//
//  NetworkEngine.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/7/28.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON



enum NeCTAREngineError : ErrorType {
    case CommonError(String?)
    case ErrorStatusCode(Int)
    case NSErrorWrapped(NSError)
}



class NeCTAREngine {
    static let sharedEngine = NeCTAREngine()
    
//    let AuthURLString = "https://keystone.rc.nectar.org.au:5000/v2/auth/tokens"
    var manager:Alamofire.Manager
    
    init(){
        let sessionConfig = Alamofire.Manager.sharedInstance.session.configuration
        sessionConfig.HTTPCookieAcceptPolicy = .Never
        sessionConfig.HTTPShouldSetCookies = false
        self.manager = Alamofire.Manager(configuration: sessionConfig)
    }
    
    func doHttpRequest(
        method:Alamofire.Method,
        _ url: String,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = .URL,
        headers: [String: String]? = nil)
        -> Promise<JSON>
    {
        var _params:[String:AnyObject]? = nil
        
        if let parameters = parameters {
            _params = parameters
          
        }
        
        return Promise() { fulfill, reject in
            let req = self.manager.request(
            method,
            url,
            parameters: _params,
            encoding: encoding,
            headers: headers)
            req.response
                {(req,resp,data,err) -> Void in
                    if let err = err {
                        reject(NeCTAREngineError.NSErrorWrapped(err))
                        return
                    }
                    if let resp = resp where resp.statusCode < 200 || resp.statusCode >= 300 {
                        reject(NeCTAREngineError.ErrorStatusCode(resp.statusCode))
                        return
                    }
                    if let data = data {
                        let json = JSON(data: data)
                        fulfill(json)
                    }
            }
        }
    }
}

// MARK: - Log in

extension NeCTAREngine {
    
    func login(tenantName: String, username: String, password: String) -> Promise<JSON> {
        let para: [String: AnyObject] = ["auth": [
            "tenantName": tenantName,
            "passwordCredentials": [
                "username": username,
                "password": password
            ]]]
        let authenticationURL = "https://keystone.rc.nectar.org.au:5000/v2.0/tokens"
        
        return doHttpRequest(.POST, authenticationURL, parameters: para, encoding: .JSON)
    }
}

// MARK: - Overall usage

extension NeCTAREngine {
    func getLimit(url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/limits"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func checkUsage(url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/os-simple-tenant-usage"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
}


// MARK: - instance management
extension NeCTAREngine {
    
    func listInstances(url:String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/detail"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func createInstance(url: String, name: String, flavor: String,
                        image: String, adminPass: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/servers"
        let para = [
            "server":[
                "name": name,
                "flavorRef": flavor,
                "imageRef": image,
                "adminPass": adminPass]]
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func deleteInstance(serverId: String, url:String, token: String) -> Promise<JSON>{
        let fullURL = url + "/servers"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: ["server_id": serverId], encoding: .URL, headers: header)
    }
}

// MARK: - instance action

extension NeCTAREngine {
    
    func instanceSecurityGroup(action: String, serverID: String,
                               url: String, sgName: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/action"
        let header = ["X-Auth-Token": token]
        var para: [String:AnyObject]
        if (action == "add"){
            para = ["addSecurityGroup": ["name":sgName]]
        }else {
            para = ["removeSecurityGroup": ["name":sgName]]
        }
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func createSnapshot(serverID: String, url: String,
                        snapshotName: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/action"
        let header = ["X-Auth-Token": token]
        let para = ["createImage": ["name":snapshotName]]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func rebuildInstance(serverID:String, url:String, image: String,
                         securityGroupName:String, token:String ) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/action"
        let header = ["X-Auth-Token": token]
        let para = ["rebuild": ["imageRef": image, "name": securityGroupName ]]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func instanceAction(serverID: String, url: String,
                        action: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/action"
        let header = ["X-Auth-Token": token]
        var para: [String: AnyObject]?
        switch action {
        case "pause":
            para = ["pause": NSNull()]
        case "unpause":
            para = ["unpause": NSNull()]
        case "lock":
            para = ["lock": NSNull()]
        case "unlock":
            para = ["unlock": NSNull()]
        case "resume":
            para = ["resume": NSNull()]
        case "start":
            para = ["os-start": NSNull()]
        case "stop":
            para = ["os-stop": NSNull()]
        case "suspend":
            para = ["suspend": NSNull()]
        case "forceDelete":
            para = ["forceDelete": NSNull()]
        default:
            ()
        }
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func rebootInstance(serverID: String, method: String,
                        url: String, token:String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/action"
        let header = ["X-Auth-Token": token]
        let para = ["reboot":["type":method]]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
}

// MARK: - instance administrative action

extension NeCTAREngine {
    
    func createBackUp(serverID: String, url: String, name: String,
                      backupType:String, rotation: Int, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/action"
        let header = ["X-Auth-Token": token]
        let para = ["createBackup":["name":name, "backup_type": backupType, "rotation": rotation]]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func showUsage(serverID: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/diagnostics"
        let header = ["X-Auth-Token": token]
        let para = ["server_id": serverID]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
}

// MARK: - Security Group

extension NeCTAREngine {
    func listSecurityGroups(serverID: String, url:String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/os-security-groups"
        let header = ["X-Auth-Token": token]
        let para = ["server_id": serverID]
        return doHttpRequest(.GET, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
}

// MARK: - volume attachment 

extension NeCTAREngine{
    func listAttachment(serverID: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/volume_attachments"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func attachVolume(serverID: String, url: String,
                      volumenID: String, device: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/volume_attachments"
        let header = ["X-Auth-Token": token]
        let para = ["volumeAttachment":["volumeId": serverID, "device": device]]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func upAttachment(serverID: String, attahmentId: String,
                      newVolumeId: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/volume_attachments/\(attahmentId)"
        let header = ["X-Auth-Token": token]
        let para = ["volumeAttachment":["volumeId": newVolumeId]]
        return doHttpRequest(.PUT, fullURL, parameters: para, encoding: .URL, headers: header)
    }
    
    func deleteAttachment(serverID: String, attahmentId: String,
                          url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/volume_attachments/\(attahmentId)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)
    }

}

// MARK: - flavors

extension NeCTAREngine {

    func listFlavors(url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/flavors/detail"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func createFlavor(url: String, token: String, name: String,
                      id: String, ram: Int, disk: Int, vcpus: Int, ephemeralDisk: Int,
                      swap: Int, rxtxFactor: Float, isPublic: Bool) -> Promise<JSON> {
        let fullURL = url + "/flavors"
        let header = ["X-Auth-Token": token]
        let para = ["flavor": ["name": name, "id": id,"ram": ram, "disk": disk, "vcpus": vcpus,
            "OS-FLV-EXT-DATA:ephemeral":ephemeralDisk, "swap": swap, "rxtx_factor": rxtxFactor,
            "os-flavor-access:is_public": isPublic]]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func deleteFlavor(url: String, token:String, flavorId:String) -> Promise<JSON> {
        let fullURL = url + "/flavors"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: ["flavor_id": flavorId],
                             encoding: .URL, headers: header)
    }
    
}

// MARK: - keypairs

extension NeCTAREngine {
    
    func createKeyPair(keyName: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "os-keypairs"
        let para = ["keypair":["name": keyName]]
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
        
    }
    
    func importKeypair(keyName: String, url: String,
                       publicKey: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/os-keypairs"
        let para = ["keypair":["name": keyName, "public_key": publicKey]]
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func listKeyPair(url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/os-keypairs"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
        
    }
    
    func keypairDetail(keyName: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/os-keypairs"
        let para = ["keypair_name": keyName]
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: para, encoding: .URL, headers: header)
    }
    
    func deleteKeyPair(keyName: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/os-keypairs"
        let para = ["keypair_name": keyName]
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: para, encoding: .URL, headers: header)
    }
}

// MARK: - snapshot

extension NeCTAREngine{
    func createVolumeSnapshot(volumeId: String, snapshotId: String, url: String,
                              name: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/os-assisted-volume-snapshots"
        let header = ["X-Auth-Token": token]
        let para = ["snapshot":["volume_id": volumeId, "create_info": ["snapshot_id": snapshotId,
            "type": "qcow2", "new_file": name]]]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func deleteVolumeSnapshot(volumeId: String, snapshotId: String, url: String,
                              token: String) -> Promise<JSON> {
        let fullURL = url + "/os-assisted-volume-snapshots"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)

    }
}

// MARK: - Images 

extension NeCTAREngine {
    func listImages(url:String, token: String) -> Promise<JSON> {
        
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, url, parameters: nil, encoding: .URL, headers: header)
    }
}


extension NeCTAREngine {

    func getSecurityGroups(url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/os-security-groups"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func createSecurityGroup(name: String, description: String,
                             url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/os-security-groups"
        let para = ["security_group": [
            "name": name,
            "description": description]]
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func deleteSecurityGroups(securityGroupID: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "os-security-groups"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: ["security_group_id": securityGroupID], encoding: .JSON, headers: header)
    }
}




