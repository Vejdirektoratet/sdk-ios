# VejdirektoratetSDK

The easiest way of getting official and up to date traffic data for the geographical region of Denmark.

[![Build Status](https://travis-ci.com/Vejdirektoratet/sdk-ios.svg?branch=master)](https://travis-ci.com/Vejdirektoratet/sdk-ios)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/VejdirektoratetSDK)](https://img.shields.io/cocoapods/v/VejdirektoratetSDK)
[![Platform](https://img.shields.io/cocoapods/p/VejdirektoratetSDK?style=flat)](https://img.shields.io/cocoapods/v/VejdirektoratetSDK)
[![License](https://img.shields.io/cocoapods/l/BadgeSwift.svg?style=flat)](/LICENSE)

## Features

- [x] Traffic events
- [x] Roadwork events
- [x] Road segments congestion status
- [x] Road segments deicing status in winter
- [x] Condition of road segments in winter
- [x] Request data from within geographical bounding box
- [x] Request single entity by `tag`

## Installation

The library can be installed using one of the below methods:

### Swift Package Manager (SPM)

Add `VejdirektoratetSDK` to your `Package.swift`

```swift
import PackageDescription

let package = Package(
dependencies: [
	package(url: "https://github.com/Vejdirektoratet/sdk-ios.git", "1.0.0")
])
```

### Cocoa Pods

Add the following line to your Podfile:

```ruby
pod 'VejdirektoratetSDK'
```

Then run

```bash
$ pod install
```

Be sure to open the generated workspace in Xcode.

## Getting started

### Configuration

An API key is needed when requesting data through this SDK.
To generate an API key you have to:

 1. Create an account on the [website](https://nap.vd.dk/register) of The Danish Road Directorate.
 2. [Generate](https://nap.vd.dk/themes/811) the API key *(while being logged in to the account created in step 1)*

### Example of requesting data

The following request will return the current Traffic and Roadwork events for the specified region. The returned data will be objects subclassing `ListEntity` suitable for a list representation due to the parameter `viewType = .List`.

```swift
import VejdirektoratetSDK

VejdirektoratetSDK.request(entityTypes: [.Traffic, .RoadWork],
                                region: mapView.region,
                              viewType: .List,
                                apiKey: self.apiKey) { result in
    switch result {
        case .entities(let entities):
            // Handle entities
        case .error(let error):
            // Handle error
        default:
            break
    }
}
```

#### Cancelling the request

The method returns a `HTTP.Request` which can be cancelled by calling

```swift
request.cancel()
```

### Request parameters

#### entityTypes

The `entityTypes` parameter is a list of `EntityType` objects defining what data is requested. The available EntityTypes are:

 - **Traffic** *(traffic events e.g. accidents)*
 - **Roadwork** *(roadworks)*
 - **TrafficDensity** *(traffic congestion of road segments)*
 - **WinterDeicing** *(deicing status of road segments)*
 - **WinterCondition** *(condition of roadsegments in winter e.g. is the segment in risk of being slippery?)*

**NOTE:** `TrafficDensity`, `WinterDeicing` and `WinterCondition` can only be used in combination with `viewType = .Map`

#### region (optional)
The `region` parameter is a bounding box of type `MKCoordinateRegion` describing the area for which to get data.

Omitting this parameter will return data for the entire region of Denmark.

#### zoom (optional)
The parameter `zoom` is a Google-maps style zoom level describing in which resolution the geometrical information should be returned.

**NOTE:** This parameter is only relevant for `viewType = .Map`

#### viewType
The `viewType` parameter defines in which format the data should be returned. Data can be returned in two formats aimed for different purposes.

 - **List** - Returns `ListEntity` objects *(for list representations of data)*
 - **Map** - Returns `MapEntity` objects *(contains geometrical information for a map representation of the data)*

#### apiKey
The `apiKey` parameter is required to get access to the available data. 
It can be generated on The Danish Road Directorate's [website](https://nap.vd.dk/themes/811)

#### completion
The `completion` parameter is a callback function for handling the result of the request. The result is returned in form of a `HTTP.Result` enum.

 - **Result.Entities** *(contains a list of requested entities)*
 - **Result.Entity** *(contains a single requested entity)*
 - **Result.Error** *(contains a RequestError)*

## Credits
VejdirektoratetSDK is brought to you by [The Danish Road Directorate](https://www.vejdirektoratet.dk/).

This SDK is using the following libraries:
 - [Alamofire](https://github.com/Alamofire/Alamofire) - A HTTP networking library for Swift.
 - [Hippolyte](https://github.com/JanGorman/Hippolyte) - A HTTP stubbing library for Swift.

Project [contributors](https://github.com/Vejdirektoratet/sdk-ios/graphs/contributors).

## Licenses

VejdirektoratetSDK is released under the [MIT](https://mit-license.org) license.
