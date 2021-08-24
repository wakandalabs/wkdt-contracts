import FungibleToken from "./FungibleToken.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc";

pub contract WakandaStorefront {
    pub event WakandaStorefrontInitialized()
    pub event StorefrontInitialized(storefrontResourceID: UInt64)
    pub event StorefrontDestroyed(storefrontResourceID: UInt64)
    pub event SaleOfferAvailable(
        storefrontAddress: Address,
        saleOfferResourceID: UInt64,
        nftType: Type,
        nftID: UInt64,
        ftVaultType: Type,
        price: UFix64
    )
    pub event SaleOfferCompleted(saleOfferResourceID: UInt64, storefrontResourceID: UInt64, accepted: Bool)

    pub let StorefrontStoragePath: StoragePath
    pub let StorefrontPublicPath: PublicPath

    pub struct SaleCut {
        pub let receiver: Capability<&{FungibleToken.Receiver}>
        pub let amount: UFix64
        init(receiver: Capability<&{FungibleToken.Receiver}>, amount: UFix64) {
            self.receiver = receiver
            self.amount = amount
        }
    }

    pub struct SaleOfferDetails {
        pub var storefrontID: UInt64
        pub var accepted: Bool
        pub let nftType: Type
        pub let nftID: UInt64
        pub let salePaymentVaultType: Type
        pub let salePrice: UFix64
        pub let saleCuts: [SaleCut]
        access(contract) fun setToAccepted() {
            self.accepted = true
        }
        init (
            nftType: Type,
            nftID: UInt64,
            salePaymentVaultType: Type,
            saleCuts: [SaleCut],
            storefrontID: UInt64
        ) {
            self.storefrontID = storefrontID
            self.accepted = false
            self.nftType = nftType
            self.nftID = nftID
            self.salePaymentVaultType = salePaymentVaultType
            assert(saleCuts.length > 0, message: "SaleOffer must have at least one payment cut recipient")
            self.saleCuts = saleCuts
            var salePrice = 0.0
            for cut in self.saleCuts {
                cut.receiver.borrow()
                    ?? panic("Cannot borrow receiver")
                salePrice = salePrice + cut.amount
            }
            assert(salePrice > 0.0, message: "SaleOffer must have non-zero price")
            self.salePrice = salePrice
        }
    }

    pub resource interface SaleOfferPublic {
        pub fun borrowNFT(): &NonFungibleToken.NFT
        pub fun accept(payment: @FungibleToken.Vault): @NonFungibleToken.NFT
        pub fun getDetails(): SaleOfferDetails
    }

    pub resource SaleOffer: SaleOfferPublic {
        access(self) let details: SaleOfferDetails
        access(contract) let nftProviderCapability: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>

        pub fun borrowNFT(): &NonFungibleToken.NFT {
            let ref = self.nftProviderCapability.borrow()!.borrowNFT(id: self.getDetails().nftID)
            assert(ref.isInstance(self.getDetails().nftType), message: "token has wrong type")
            assert(ref.id == self.getDetails().nftID, message: "token has wrong ID")
            return ref as &NonFungibleToken.NFT
        }

        pub fun getDetails(): SaleOfferDetails {
            return self.details
        }

        pub fun accept(payment: @FungibleToken.Vault): @NonFungibleToken.NFT {
            pre {
                self.details.accepted == false: "offer has already been accepted"
                payment.isInstance(self.details.salePaymentVaultType): "payment vault is not requested fungible token"
                payment.balance == self.details.salePrice: "payment vault does not contain requested price"
            }

            self.details.setToAccepted()
            let nft <-self.nftProviderCapability.borrow()!.withdraw(withdrawID: self.details.nftID)

            assert(nft.isInstance(self.details.nftType), message: "withdrawn NFT is not of specified type")
            assert(nft.id == self.details.nftID, message: "withdrawn NFT does not have specified ID")
            var residualReceiver: &{FungibleToken.Receiver}? = nil

            for cut in self.details.saleCuts {
                if let receiver = cut.receiver.borrow() {
                   let paymentCut <- payment.withdraw(amount: cut.amount)
                    receiver.deposit(from: <-paymentCut)
                    if (residualReceiver == nil) {
                        residualReceiver = receiver
                    }
                }
            }

            assert(residualReceiver != nil, message: "No valid payment receivers")
            residualReceiver!.deposit(from: <-payment)
            emit SaleOfferCompleted(
                saleOfferResourceID: self.uuid,
                storefrontResourceID: self.details.storefrontID,
                accepted: self.details.accepted
            )
            return <-nft
        }
        destroy () {
            if !self.details.accepted {
              log("Destroying sale offer")
                emit SaleOfferCompleted(
                    saleOfferResourceID: self.uuid,
                    storefrontResourceID: self.details.storefrontID,
                    accepted: self.details.accepted
                )
            }
        }
        init (
            nftProviderCapability: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>,
            nftType: Type,
            nftID: UInt64,
            salePaymentVaultType: Type,
            saleCuts: [SaleCut],
            storefrontID: UInt64
        ) {
            self.details = SaleOfferDetails(
                nftType: nftType,
                nftID: nftID,
                salePaymentVaultType: salePaymentVaultType,
                saleCuts: saleCuts,
                storefrontID: storefrontID
            )
            self.nftProviderCapability = nftProviderCapability
            let provider = self.nftProviderCapability.borrow()
            assert(provider != nil, message: "cannot borrow nftProviderCapability")
            let nft = provider!.borrowNFT(id: self.details.nftID)
            assert(nft.isInstance(self.details.nftType), message: "token is not of specified type")
            assert(nft.id == self.details.nftID, message: "token does not have specified ID")
        }
    }

    pub resource interface StorefrontManager {
        pub fun createSaleOffer(
            nftProviderCapability: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>,
            nftType: Type,
            nftID: UInt64,
            salePaymentVaultType: Type,
            saleCuts: [SaleCut]
        ): UInt64
        pub fun removeSaleOffer(saleOfferResourceID: UInt64)
    }

    pub resource interface StorefrontPublic {
        pub fun getSaleOfferIDs(): [UInt64]
        pub fun borrowSaleOffer(saleOfferResourceID: UInt64): &SaleOffer{SaleOfferPublic}?
        pub fun cleanup(saleOfferResourceID: UInt64)
    }

    pub resource Storefront : StorefrontManager, StorefrontPublic {
        access(self) var saleOffers: @{UInt64: SaleOffer}
         pub fun createSaleOffer(
            nftProviderCapability: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>,
            nftType: Type,
            nftID: UInt64,
            salePaymentVaultType: Type,
            saleCuts: [SaleCut]
         ): UInt64 {
            let saleOffer <- create SaleOffer(
                nftProviderCapability: nftProviderCapability,
                nftType: nftType,
                nftID: nftID,
                salePaymentVaultType: salePaymentVaultType,
                saleCuts: saleCuts,
                storefrontID: self.uuid
            )
            let saleOfferResourceID = saleOffer.uuid
            let saleOfferPrice = saleOffer.getDetails().salePrice
            let oldOffer <- self.saleOffers[saleOfferResourceID] <- saleOffer
            destroy oldOffer
            emit SaleOfferAvailable(
                storefrontAddress: self.owner?.address!,
                saleOfferResourceID: saleOfferResourceID,
                nftType: nftType,
                nftID: nftID,
                ftVaultType: salePaymentVaultType,
                price: saleOfferPrice
            )
            return saleOfferResourceID
        }

        pub fun removeSaleOffer(saleOfferResourceID: UInt64) {
            let offer <- self.saleOffers.remove(key: saleOfferResourceID)
                ?? panic("missing SaleOffer")
            destroy offer
        }

        pub fun getSaleOfferIDs(): [UInt64] {
            return self.saleOffers.keys
        }

        pub fun borrowSaleOffer(saleOfferResourceID: UInt64): &SaleOffer{SaleOfferPublic}? {
            if self.saleOffers[saleOfferResourceID] != nil {
                return &self.saleOffers[saleOfferResourceID] as! &SaleOffer{SaleOfferPublic}
            } else {
                return nil
            }
        }

        pub fun cleanup(saleOfferResourceID: UInt64) {
            pre {
                self.saleOffers[saleOfferResourceID] != nil: "could not find offer with given id"
            }

            let offer <- self.saleOffers.remove(key: saleOfferResourceID)!
            assert(offer.getDetails().accepted == true, message: "offer is not accepted, only admin can remove")
            destroy offer
        }

        destroy () {
            destroy self.saleOffers
            emit StorefrontDestroyed(storefrontResourceID: self.uuid)
        }

        init () {
            self.saleOffers <- {}
            emit StorefrontInitialized(storefrontResourceID: self.uuid)
        }
    }

    pub fun createStorefront(): @Storefront {
        return <-create Storefront()
    }

    pub fun check(_ address: Address): Bool {
         return getAccount(address)
         .getCapability<&{WakandaStorefront.StorefrontPublic}>(WakandaStorefront.StorefrontPublicPath)
         .check()
    }

    init () {
        self.StorefrontStoragePath = /storage/wakandaStorefront06
        self.StorefrontPublicPath = /public/wakandaStorefront06
        emit WakandaStorefrontInitialized()
    }
}
