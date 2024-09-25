# DIDPay

> [!WARNING]
> This repo is very much so in its early stages. 🚧

## Summary

DIDPay is an open source mobile app that provides a way for individuals to interact with PFIs via tbDEX. Concretely, DIDPay provides a UI for individuals to interface with PFIs.

## 🎉 Hacktoberfest 2024 🎉

`didpay` is a participating project in Hacktoberfest 2024! We’re so excited for your contributions, and have created a wide variety of issues so that anyone can contribute. Whether you're a seasoned developer or a first-time open source contributor, there's something for everyone.

### To get started:
1. Read the [contributing guide](https://github.com/TBD54566975/didpay/blob/main/CONTRIBUTING.md).
2. Read the [code of conduct](https://github.com/TBD54566975/didpay/blob/main/CODE_OF_CONDUCT.md).
3. Choose a task from this project's Hacktoberfest issues in our [Project Hub](https://github.com/TBD54566975/didpay/issues/298) and follow the instructions. Each issue has the 🏷️ `hacktoberfest` label.

Have questions? Connecting with us in our [Discord community](https://discord.gg/tbd) in the `#hacktoberfest` project channel.

---

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
