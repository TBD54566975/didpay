# DIDPay

> [!WARNING]
> This repo is very much so in its early stages. 🚧

## Summary

DIDPay is an open source mobile app that provides a way for individuals to interact with PFIs via tbDEX. Concretely, DIDPay provides a UI for individuals to interface with PFIs.

## Local Development

### Prerequisites

#### Visual Studio Code

Visual Studio Code is the recommended IDE to use with DIDPay.

##### Installation

Visual Studio Code can be installed [here](https://code.visualstudio.com/download).

#### Xcode

Xcode is required to run DIDPay as an iOS application using the XCode Simulator.

##### Installation

XCode can be installed through the Mac App Store. We recommend using `Xcode 15.3` and `iOS 17.4` as the XCode Simulator version.

#### Android Studio

Android Studio is required to run DIDPay as an Android application using the Android Emulator.

##### Installation

Android Studio can be installed by following instructions [here](https://developer.android.com/studio/install).

### Running Locally

#### Initial Setup

```bash
git clone git@github.com:TBD54566975/didpay.git
cd didpay

. ./bin/activate-hermit
hermit install-hooks
```

> [!TIP]
> We use [Just](https://github.com/casey/just) to manage our local development tasks. To see what tasks are available, run `just -l` (list).

#### Starting development

Run the following command to get the latest Dart/Flutter packages:

```bash
just get
```

Next, open up the Command Palette in Visual Studio Code with the shortcut:

- Windows/Linux: `Ctrl+Shift+P`
- macOS: `Cmd+Shift+P`

Search for `Flutter: Select Device` to bring up a list of available devices.

Select your preferred device (i.e. if you want to run DIDPay on the iOS simulator, hit `Start iOS Simulator` and wait for the simulator to boot up).

Run the following command to build and start DIDPay on the selected simulator/device:

```bash
just run
```
