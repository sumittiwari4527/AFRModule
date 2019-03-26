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
const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' + 'Cmd+D or shake for dev menu',
  android:
    'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});

type Props = {};

export function getSecurityType(type)
  {
    switch(type)
    {
      case "0":
      return 'Open'
      break;
      case "1":
      return 'WEP'
      break;
      case "2":
      return 'WPA'
      break;
      case "3":
      return 'WPA2'
      break;
      case "4":
      return 'Unsupported'
      break;
      default:
      return 'Unsupported'
      break;
    }
  }
export const AFREventEmitter = new NativeEventEmitter(NativeModules.AFROperations)
export function scanDeviceReady()
{
  NativeModules.AFROperations.scanReady();
}
export function scanWifiReady()
{
  NativeModules.AFROperations.scanWifiReady()
}
export function scanDevice()
{
  NativeModules.AFROperations.scanDevice();
}
export function connect(identifier)
{
  NativeModules.AFROperations.connect(identifier)
}
export function disconnect(identifier)
{
  NativeModules.AFROperations.disconnect(identifier)
}
export function rescanDevice()
{
  NativeModules.AFROperations.rescanDevice()
}
export function provision(identifier,ssid,isSave,password)
{
  NativeModules.AFROperations.provisionWifi(identifier,ssid,isSave,password)

}
export function removeSavedWifi(identifier,key)
{
  NativeModules.AFROperations.removeWifi(identifier,parseInt(key))
}

export function listWifiNetwork(identifier)
{
  NativeModules.AFROperations.listWifiNetwork(identifier)
}
