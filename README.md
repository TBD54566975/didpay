# DidPay - pay anyone with tbdex

DidPay is a general purpose front end for tbdex that can be used or forked and modified. It runs as a mobile app. 

## Introduction

This is EXTREMELY a work in progress. 
The aim is that this app can work with any tbdex liquidity node, discoverying the offerings and then running transactions all from a phone. 

## Running

* Install Hermit https://cashapp.github.io/hermit/ (on macos you can run `brew install hermit` and then `hermit shell-hooks`)
* Ensure you have a mobile app simulator handy (XCode on macOS and runing the Simulator app will do for example)
* Run `flutter run` from this project to build and start the app in the simulator. Use `flutter run --dart-define=DEV_PFI=your_did_string` to run against a local tbdex liquidity node at dev time.



A picture says a thousand words: 

![shot1](https://github.com/TBD54566975/didpay/assets/14976/fe4600fa-9843-4770-ba6a-9e1bc4234d0d)

![shot2](https://github.com/TBD54566975/didpay/assets/14976/64948141-311e-41fb-a0b7-fe2160fd36be)

## Project Resources

| Resource                                   | Description                                                                    |
| ------------------------------------------ | ------------------------------------------------------------------------------ |
| [CODEOWNERS](./CODEOWNERS)                 | Outlines the project lead(s)                                                   |
| [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) | Expected behavior for project contributors, promoting a welcoming environment |
| [CONTRIBUTING.md](./CONTRIBUTING.md)       | Developer guide to build, test, run, access CI, chat, discuss, file issues     |
| [GOVERNANCE.md](./GOVERNANCE.md)           | Project governance                                                             |
| [LICENSE](./LICENSE)                       | Apache License, Version 2.0                                                    |
