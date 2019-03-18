import Foundation
import AmazonFreeRTOS
import CoreBluetooth
import UIKit

@objc(AFROperations)
class AFROperations: RCTEventEmitter {
  
  var peripherals: [String:CBPeripheral]?
  private var count=0;
  var refreshControl:UIRefreshControl?
  var selectedPeriPheral:String?
  var routerList:[String:[[ListNetworkResp]]]?
  @objc
  func scanReady() {
    print("Scan is ---------\(count)")
    NotificationCenter.default.addObserver(self, selector: #selector(scanDevice), name: .afrCentralManagerDidUpdateState, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(scanDevice), name: .afrCentralManagerDidDiscoverPeripheral, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(scanDevice), name: .afrCentralManagerDidConnectPeripheral, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(scanDevice), name: .afrCentralManagerDidDisconnectPeripheral, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(scanDevice), name: .afrCentralManagerDidFailToConnectPeripheral, object: nil)
  }
  @objc
  func scanWifiReady() {
    print("Scan is ---------\(count)")
    
    // ListNetwork returned one network
    NotificationCenter.default.addObserver(self, selector: #selector(networkFound), name: .afrDidListNetwork, object: nil)
    // Refresh list on network operations
    NotificationCenter.default.addObserver(self, selector: #selector(optNetwork), name: .afrDidSaveNetwork, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(optNetwork), name: .afrDidEditNetwork, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(optNetwork), name: .afrDidDeleteNetwork, object: nil)
    
//    refreshControl?.addTarget(self, action: #selector(optNetwork), for: .valueChanged)
  }
  @objc
  func networkFound()
  {
//    refreshControl?.endRefreshing()
//    listWifiNetwork(selectedPeriPheral!)
    print("Hellooo-------\(AmazonFreeRTOSManager.shared.networks)")
    routerList=AmazonFreeRTOSManager.shared.networks
    var savedwifiList=AmazonFreeRTOSManager.shared.networks[selectedPeriPheral!]?[0]
    var wifiList=AmazonFreeRTOSManager.shared.networks[selectedPeriPheral!]?[1]
    var routers:[NSObject]=[]
    var savedrouters:[NSObject]=[]
    for router in savedwifiList ?? []
    {
      savedrouters.append("{\"key\":\"\(router.index)\",\"status\":\"\(router.status.rawValue)\",\"ssid\":\"\(router.ssid)\",\"bssid\":\"\(router.bssid)\",\"rssi\":\"\(router.rssi)\",\"security\":\"\(router.security.rawValue)\",\"hidden\":\"\(router.hidden)\",\"connected\":\"\(router.connected)\"}" as NSObject)
    }
    for router in wifiList ?? []
    {
      routers.append("{\"key\":\"\(router.index)\",\"status\":\"\(router.status.rawValue)\",\"ssid\":\"\(router.ssid)\",\"bssid\":\"\(router.bssid)\",\"rssi\":\"\(router.rssi)\",\"security\":\"\(router.security.rawValue)\",\"hidden\":\"\(router.hidden)\",\"connected\":\"\(router.connected)\"}" as NSObject)
    }
    var payload="{\"saved\":\(savedrouters),\"unsaved\":\(routers)}"
    sendEvent(withName: "onWifiRouterFound", body: ["routers": payload])
  }
  @objc
  func optNetwork()
  {
//    refreshControl?.endRefreshing()
    print("Yoo------\(selectedPeriPheral)")
    listWifiNetwork(selectedPeriPheral!)
    print("Hellooo-------\(AmazonFreeRTOSManager.shared.networks.count)")
  }
  
  @objc
  func scanDevice() {
//    AmazonFreeRTOSManager.shared.rescanForPeripherals()
    let peripheralValue:[CBPeripheral]?
    peripheralValue=Array(AmazonFreeRTOSManager.shared.peripherals.values)
    peripherals=AmazonFreeRTOSManager.shared.peripherals
    count=AmazonFreeRTOSManager.shared.peripherals.count
    print("Count is ---------\(count)")
    var peripheralList:[NSObject]=[]
    for peripheral in peripheralValue ?? []
    {
      peripheralList.append("{\"identifier\": \"\(peripheral.identifier)\", \"name\": \"\((peripheral.name)!)\",\"state\": \"\(peripheral.state.rawValue)\"}" as NSObject)
      
    }
    print("\(peripherals)")
    sendEvent(withName: "onDeviceFound", body: ["peripherals": peripheralList])
  }
  @objc
  func rescanDevice()
  {
  AmazonFreeRTOSManager.shared.rescanForPeripherals()
    scanDevice()
  }
  @objc
  func listWifiNetwork(_ peripheralId:String)
  {
    selectedPeriPheral=peripheralId
    print("Hellooo-------\((peripherals?[peripheralId])!)")
    AmazonFreeRTOSManager.shared.listNetworkOfPeripheral((peripherals?[peripheralId])!, listNetworkReq: ListNetworkReq(maxNetworks: 50, timeout: 3))
  }
  @objc
  func connect(_ peripheralId:String)
  {
    print("Helloooooooooooo \(peripherals?[peripheralId])")
    if(peripherals?[peripheralId]?.state != .connected)
    {
      selectedPeriPheral=peripheralId
      AmazonFreeRTOSManager.shared.connectPeripheral((peripherals?[peripheralId])!)
      scanDevice()
    }
    else
    {
    print("Already Connected")
    }
  }
  @objc
  func disconnect(_ peripheralId:String)
  {
    print("Helloooooooooooo \(peripherals?[peripheralId])")
    if(peripherals?[peripheralId]?.state == .connected)
    {
      selectedPeriPheral=nil
      AmazonFreeRTOSManager.shared.disconnectPeripheral((peripherals?[peripheralId])!)
      scanDevice()
    }
    else
    {
      print("Already disconnected")
    }
  }
  @objc(provisionWifi:ssid:save:pwd:)
  func provisionWifi(peripheralId:String,ssid:String,save:Bool,pwd:String)
  {
    
    var selectedRouter:ListNetworkResp?
    for router in routerList?[peripheralId]![1] ?? []
    {
      if(router.ssid == ssid)
      {
         selectedRouter=router
        break;
      }
    
    }
    for router in routerList?[peripheralId]![0] ?? []
    {
      if(router.ssid == ssid)
      {
        selectedRouter=router
        break;
      }
      
    }
    print("Wifi------\((peripherals?[peripheralId])!)----\(save)")
  
    AmazonFreeRTOSManager.shared.saveNetworkToPeripheral((peripherals?[peripheralId])!, saveNetworkReq: SaveNetworkReq(index: (selectedRouter?.index)!, ssid: ssid, bssid: selectedRouter?.bssid ?? "000000000000", psk: pwd ?? String(), security: (selectedRouter?.security)!, connect: save))
 
  }
  
  @objc(removeWifi:index:)
  func removeWifi(peripheralId:String,index:Int)
  {
    print("remove------\(peripheralId)----\(index)")
  AmazonFreeRTOSManager.shared.deleteNetworkFromPeripheral((peripherals?[peripheralId])!, deleteNetworkReq: DeleteNetworkReq(index: index))
  }
  
  
  
  @objc
  func listDevice(_ callback: RCTResponseSenderBlock) {
    count=AmazonFreeRTOSManager.shared.peripherals.count
    callback([count])
  }
  override func supportedEvents() -> [String]! {
    return ["onDeviceFound","onWifiRouterFound"]
  }
  @objc
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}
