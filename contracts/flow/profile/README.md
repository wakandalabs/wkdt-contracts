====================
## Table of Contents
====================
                                                               Line
Intro .........................................................   1
Table of Contents .............................................  27
General WakandaProfile Contract Info .................................  41
Examples ......................................................  50
Initializing a WakandaProfile Resource .............................  59
Interacting with WakandaProfile Resource (as Owner) ................ 112
Reading a WakandaProfile Given a Flow Address ...................... 160
Reading a Multiple WakandaProfiles Given Multiple Flow Addresses ... 192
Checking if Flow Account is Initialized ..................... 225


================================
## General WakandaProfile Contract Info
================================

Current a WakandaProfile consists of a couple main pieces:
- name – An alias the WakandaProfile owner would like to be referred as.
- avatar - An href the WakandaProfile owner would like applications to use to represent them graphically.
- color - A valid html color (not verified in any way) applications can use to accent and personalize the experience.
- info - A short description about the account.

===========
## Examples
===========

The following examples will include both raw cadence transactions and scripts
as well as how you can call them from FCL. The FCL examples are currently assuming
the following configuration is called somewhere in your application before the
the actual calls to the chain are invoked.

==================================
## Initializing a WakandaProfile Resource
==================================

Initializing should be done using the paths that the contract exposes.
This will lead to predictability in how applications can look up the data.

-----------
### Cadence
-----------

    import WakandaProfile from 0xWakandaProfile

    transaction {
      let address: address
      prepare(currentUser: AuthAccount) {
        self.address = currentUser.address
        if !WakandaProfile.check(self.address) {
          currentUser.save(<- WakandaProfile.new(), to: WakandaProfile.privatePath)
          currentUser.link<&WakandaProfile.Base{WakandaProfile.Public}>(WakandaProfile.publicPath, target: WakandaProfile.privatePath)
        }
      }
      post {
        WakandaProfile.check(self.address): "Account was not initialized"
      }
    }
    
-------
### FCL
-------

    import {query} from "@onflow/fcl"

    await mutate({
      cadence: `
        import WakandaProfile from 0xWakandaProfile
    
        transaction {
          prepare(currentUser: AuthAccount) {
            self.address = currentUser.address
            if !WakandaProfile.check(self.address) {
              currentUser.save(<- WakandaProfile.new(), to: WakandaProfile.privatePath)
              currentUser.link<&WakandaProfile.Base{WakandaProfile.Public}>(WakandaProfile.publicPath, target: WakandaProfile.privatePath)
            }
          }
          post {
            WakandaProfile.check(self.address): "Account was not initialized"
          }
        }
      `,
      limit: 55,
    })

===============================================
## Interacting with WakandaProfile Resource (as Owner)
===============================================

As the owner of a resource you can update the following:
- name using `.setName("MyNewName")` (as long as you are verified)
- avatar using `.setAvatar("https://url.to.my.avatar")`
- color using `.setColor("tomato")`
- info using `.setInfo("I like to make things with Flow :wave:")`

-----------
### Cadence
-----------

    import WakandaProfile from 0xWakandaProfile

    transaction(name: String) {
      prepare(currentUser: AuthAccount) {
        currentUser
          .borrow<&{WakandaProfile.Owner}>(from: WakandaProfile.privatePath)!
          .setName(name)
      }
    }
    
-------
### FCL
-------

    import {mutate} from "@onflow/fcl"

    await mutate({
      cadence: `
        import WakandaProfile from 0xWakandaProfile
    
        transaction(name: String) {
          prepare(currentUser: AuthAccount) {
            currentUser
              .borrow<&{WakandaProfile.Owner}>(from: WakandaProfile.privatePath)!
              .setName(name)
          }
        }
      `,
      args: (arg, t) => [
        arg("qvvg", t.String),
      ],
      limit: 55,
    })

=========================================
## Reading a WakandaProfile Given a Flow Address
=========================================

-----------
### Cadence
-----------

    import WakandaProfile from 0xWakandaProfile

    pub fun main(address: Address): WakandaProfile.ReadOnly? {
      return WakandaProfile.read(address)
    }
    
-------
### FCL
-------

    import {query} from "@onflow/fcl"

    await query({
      cadence: `
        import WakandaProfile from 0xWakandaProfile
    
        pub fun main(address: Address): WakandaProfile.ReadOnly? {
          return WakandaProfile.read(address)
        }
      `,
      args: (arg, t) => [
        arg("0xWakandaProfile", t.Address)
      ]
    })

============================================================
## Reading a Multiple WakandaProfiles Given Multiple Flow Addresses
============================================================

-----------
### Cadence
-----------

    import WakandaProfile from 0xWakandaProfile

    pub fun main(addresses: [Address]): {Address: WakandaProfile.ReadOnly} {
      return WakandaProfile.readMultiple(addresses)
    }
    
-------
### FCL
-------

    import {query} from "@onflow/fcl"

    await query({
      cadence: `
        import WakandaProfile from 0xWakandaProfile
    
        pub fun main(addresses: [Address]): {Address: WakandaProfile.ReadOnly} {
          return WakandaProfile.readMultiple(addresses)
        }
      `,
      args: (arg, t) => [
        arg(["0xWakandaProfile", "0xf76a4c54f0f75ce4", "0xf117a8efa34ffd58"], t.Array(t.Address)),
      ]
    })

==========================================
## Checking if Flow Account is Initialized
==========================================

-----------
### Cadence
-----------

    import WakandaProfile from 0xWakandaProfile

    pub fun main(address: Address): Bool {
      return WakandaProfile.check(address)
    }
    
-------
### FCL
-------

    import {query} from "@onflow/fcl"

    await query({
      cadence: `
        import WakandaProfile from 0xWakandaProfile
    
        pub fun main(address: Address): Bool {
          return WakandaProfile.check(address)
        }
      `,
      args: (arg, t) => [
        arg("0xWakandaProfile", t.Address)
      ]
    })