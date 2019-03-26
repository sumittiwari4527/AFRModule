/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 * @lint-ignore-every XPLATJSCOPYRIGHT1
 */

import React, {Component} from 'react';
import {Platform, StyleSheet, Text, View,NativeModules,NativeEventEmitter,FlatList,TouchableOpacity,Button,TextInput} from 'react-native';
import {AFREventEmitter,scanDeviceReady,scanWifiReady,scanDevice,connect,disconnect,rescanDevice,provision,removeSavedWifi,listWifiNetwork,getSecurityType} from './AFRModule'
const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' + 'Cmd+D or shake for dev menu',
  android:
    'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});

type Props = {};

  
export default class App extends Component<Props> {
  constructor(props)
  {
    super(props);
    this.deviceFound=this.deviceFound.bind(this);
    this.wifiOperation=this.wifiOperation.bind(this)
    this.wifiRouterFound=this.wifiRouterFound.bind(this)
    this.connectOperation=this.connectOperation.bind(this)
    this.state={
      devices:[],
      selectedDevice:null,
      routers:null,
      selectedRouter:null,
      passwordScreen:false,
      password:'',
      save:false,
      remove:false
    }

     // const onDeviceFound = new NativeEventEmitter(NativeModules.AFROperations)
// subscribe to event
AFREventEmitter.addListener(
  "onDeviceFound",
  res =>this.deviceFound(res)
)
AFREventEmitter.addListener(
  "onWifiRouterFound",
  res=>this.wifiRouterFound(res)
  )

  }
  componentDidMount() {

    // NativeModules.AFROperations.scanReady();
    scanDeviceReady();
    // NativeModules.AFROperations.scanWifiReady()
    scanWifiReady();
      //NativeModules.AFROperations.scanDevice();
      scanDevice();

  }
  wifiRouterFound(res)
  {
    this.setState({routers:JSON.parse(res.routers)})
    console.log(JSON.parse(res.routers).saved)
  }

  deviceFound(res)
  {
  var peripherals=[]
  var peripheral
    for (var i=0;i<res.peripherals.length;i++)
    {
      // alert(res.peripherals[i])
peripherals.push({key:JSON.parse(res.peripherals[i]).identifier,value:JSON.parse(res.peripherals[i])})
    }
    // alert(JSON.stringify(peripherals))
    this.setState({devices:peripherals});
    console.log(res.peripherals)
  }

  connectOperation(item)
  {
    if(item.value.state == 0)
    {
      // NativeModules.AFROperations.connect(item.value.identifier)
      connect(item.value.identifier)
      this.setState({selectedDevice:item})
    }
    else
    {
      // NativeModules.AFROperations.disconnect(item.value.identifier)
      disconnect(item.value.identifier);
      // NativeModules.AFROperations.rescanDevice()
      rescanDevice();
      this.setState({routers:[]})
    }
    //rescanDevicec

  }
  removeOperation(item)
  {
// NativeModules.AFROperations.removeWifi(this.state.selectedDevice.value.identifier,parseInt(item.key))
removeSavedWifi(this.state.selectedDevice.value.identifier,item.key)
  }
  wifiOperation(item)
  {
// NativeModules.AFROperations.provisionWifi(this.state.selectedDevice.value.identifier,item.ssid,this.state.save,this.state.password)
provision(this.state.selectedDevice.value.identifier,item.ssid,this.state.save,this.state.password)
this.setState({selectedRouter:item})
  }

  render() {
// console.log(this.state.devices)
    return (
      <View style={styles.container}>
      <View style={{flex:0.5,flexDirection:'row',justifyContent:'center',alignItems:'center'}}>
      <Button onPress={()=>{listWifiNetwork(this.state.selectedDevice.value.identifier)}} title={'List WiFi'} />
      <Button onPress={()=>{rescanDevice();}} title={'Scan'} />
      <Button onPress={()=>{this.setState({save:!this.state.save})}} title={this.state.save ? 'Connect-Mode' :'Save-Mode'} />
      <Button onPress={()=>{this.setState({remove:!this.state.remove})}} title={this.state.remove ? 'Remove-On' :'Remove-Off'} />
      </View>
      <View style={{flex:0.3,flexDirection:'row',justifyContent:'center',alignItems:'stretch'}}>
      <TextInput
        style={{height: 40,width:300,borderColor: 'gray', borderWidth: 1}}
        onChangeText={(text) => this.setState({password:text})}
        value={this.state.password}
      />
      </View>
      <View style={{flex:0.7,alignItems:'center',borderWidth:2,borderColor:'black'}}>
      {
        this.state.devices.length >0 ?
        <FlatList
          data={this.state.devices}
          renderItem={({item}) => <TouchableOpacity style={{borderWidth:item.value.state == 2 ? 2:0,padding:10,borderColor:'green'}} onPress={()=>this.connectOperation(item)}><Text style={styles.item}>{item.value.name}</Text></TouchableOpacity>}
        />:<Text style={styles.item}>{'No Devices'}</Text>
      }
      </View>
      <View style={{flex:1,alignItems:'center',justifyContent:'flex-start',borderWidth:2,borderColor:'green'}}>
      {
        this.state.routers!=null && this.state.routers.saved && this.state.routers.saved.length >0 ?
        <FlatList
          data={this.state.routers.saved}
          renderItem={({item}) => <TouchableOpacity style={{borderWidth:0,padding:10,borderColor:'green'}} onPress={()=>{this.state.remove ? this.removeOperation(item):this.wifiOperation(item)}}><Text style={styles.item}>{item.ssid+"----"+getSecurityType(item.security)+"---"+item.connected}</Text></TouchableOpacity>}
        />
        :<Text style={styles.item}>{'No routers'}</Text>
      }
      </View>
      <View style={{flex:1,alignItems:'center',justifyContent:'flex-start',borderWidth:2,borderColor:'blue'}}>
      {
        this.state.routers!=null && this.state.routers.unsaved && this.state.routers.unsaved.length >0 ?
        <FlatList
          data={this.state.routers.unsaved}
          renderItem={({item}) => <TouchableOpacity style={{borderWidth:0,padding:10,borderColor:'green'}} onPress={()=>this.wifiOperation(item)}><Text style={styles.item}>{item.ssid+"----"+getSecurityType(item.security)+"---"+item.connected}</Text></TouchableOpacity>}
        />
        :<Text style={styles.item}>{'No routers'}</Text>
      }
      </View>
      </View>
    );
  }
}

// alert(this.state.devices)
//     setTimeout(() =>NativeModules.AFROperations.listDevice(value => {
// console.log("Yo " + value)
// setTimeout(() =>NativeModules.AFROperations.listDevice(value => {
// console.log("Yo " + value)
// }) , 10000);
// }) , 10000);


const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'stretch',
    backgroundColor: '#F5FCFF',
    padding:10
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
  item: {
    fontSize: 18,
    height: 44,
  }
});
