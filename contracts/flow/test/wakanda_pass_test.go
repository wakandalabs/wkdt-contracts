package test

import (
	"strings"
	"testing"

	"github.com/onflow/cadence"
	emulator "github.com/onflow/flow-emulator"
	flow "github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
	"github.com/onflow/flow-go-sdk/templates"
	flowgo "github.com/onflow/flow-go/model/flow"
	"github.com/stretchr/testify/assert"

	nft_contracts "github.com/onflow/flow-nft/lib/go/contracts"
)

const (
	wpGetWakandaPassVaultBalancePath = projectRootPath + "/scripts/token/getWakandaPassVaultBalance.cdc"
	wpMintWakandaPassPath            = projectRootPath + "/transactions/token/admin/mintWakandaPass.cdc"
	wpSetupWakandaPassCollectionPath = projectRootPath + "/transactions/token/setupWakandaPassCollection.cdc"
)

type TestWakandaPassContractsInfo struct {
	FTAddr          flow.Address
	NFTAddr         flow.Address
	VAddr           flow.Address
	VSigner         crypto.Signer
	VStakingAddr    flow.Address
	VStakingSigner  crypto.Signer
	WPAddr          flow.Address
	WPSigner        crypto.Signer
}

func WakandaPassDeployContract(b *emulator.Blockchain, t *testing.T) TestWakandaPassContractsInfo {
	// Should be able to deploy a contract as a new account with no keys.
	nftCode := loadNonFungibleToken()
	nftAddr, err := b.CreateAccount(
		nil,
		[]templates.Contract{
			{
				Name:   "NonFungibleToken",
				Source: string(nftCode),
			},
		})
	if !assert.NoError(t, err) {
		t.Log(err.Error())
	}
	_, err = b.CommitBlock()
	assert.NoError(t, err)

	btStakingInfo := VibraniumStakingDeployContract(b, t)

	wakandaPassStampCode := loadWakandaPassStamp(nftAddr)

	latestBlock, err := b.GetLatestBlock()
	assert.NoError(t, err)

	btStakingAccount, err := b.GetAccount(btStakingInfo.VStakingAddr)
	assert.NoError(t, err)

	tx := templates.AddAccountContract(
		btStakingInfo.VStakingAddr,
		templates.Contract{
			Name:   "WakandaPassStamp",
			Source: string(wakandaPassStampCode),
		},
	)

	tx.SetGasLimit(flowgo.DefaultMaxTransactionGasLimit).
		SetReferenceBlockID(flow.Identifier(latestBlock.ID())).
		SetProposalKey(btStakingInfo.VStakingAddr, btStakingAccount.Keys[0].Index, btStakingAccount.Keys[0].SequenceNumber).
		SetPayer(btStakingInfo.VStakingAddr)

	err = tx.SignEnvelope(btStakingInfo.VStakingAddr, btStakingAccount.Keys[0].Index, btStakingInfo.VStakingSigner)
	assert.NoError(t, err)

	err = b.AddTransaction(*tx)
	assert.NoError(t, err)

	_, _, err = b.ExecuteAndCommitBlock()
	assert.NoError(t, err)

	wakandaPassCode := loadWakandaPass(btStakingInfo, nftAddr)

	latestBlock, err = b.GetLatestBlock()
	assert.NoError(t, err)

	btStakingAccount, err = b.GetAccount(btStakingInfo.VStakingAddr)
	assert.NoError(t, err)

	tx = templates.AddAccountContract(
		btStakingInfo.VStakingAddr,
		templates.Contract{
			Name:   "WakandaPass",
			Source: string(wakandaPassCode),
		},
	)

	tx.SetGasLimit(flowgo.DefaultMaxTransactionGasLimit).
		SetReferenceBlockID(flow.Identifier(latestBlock.ID())).
		SetProposalKey(btStakingInfo.VStakingAddr, btStakingAccount.Keys[0].Index, btStakingAccount.Keys[0].SequenceNumber).
		SetPayer(btStakingInfo.VStakingAddr)

	err = tx.SignEnvelope(btStakingInfo.VStakingAddr, btStakingAccount.Keys[0].Index, btStakingInfo.VStakingSigner)
	assert.NoError(t, err)

	err = b.AddTransaction(*tx)
	assert.NoError(t, err)

	_, _, err = b.ExecuteAndCommitBlock()
	assert.NoError(t, err)

	return TestWakandaPassContractsInfo{
		FTAddr:          btStakingInfo.FTAddr,
		NFTAddr:         nftAddr,
		VAddr:           btStakingInfo.VAddr,
		VSigner:         btStakingInfo.VSigner,
		VStakingAddr:    btStakingInfo.VStakingAddr,
		VStakingSigner:  btStakingInfo.VStakingSigner,
		WPAddr:          btStakingInfo.VStakingAddr,
		WPSigner:        btStakingInfo.VStakingSigner,
	}
}

func loadWakandaPassStamp(nftAddr flow.Address) []byte {
	code := string(readFile(wakandaPassStampPath))

	code = strings.ReplaceAll(code, "\"./NonFungibleToken.cdc\"", "0x"+nftAddr.String())

	return []byte(code)
}

func loadWakandaPass(btStakingInfo TestVibraniumStakingContractsInfo, nftAddr flow.Address) []byte {
	code := string(readFile(wakandaPassPath))

	code = strings.ReplaceAll(code, "\"./FungibleToken.cdc\"", "0x"+btStakingInfo.FTAddr.String())
	code = strings.ReplaceAll(code, "\"./NonFungibleToken.cdc\"", "0x"+nftAddr.String())
	code = strings.ReplaceAll(code, "\"./Vibranium.cdc\"", "0x"+btStakingInfo.VAddr.String())
	code = strings.ReplaceAll(code, "\"../staking/VibraniumStaking.cdc\"", "0x"+btStakingInfo.VStakingAddr.String())
	code = strings.ReplaceAll(code, "\"./WakandaPassStamp.cdc\"", "0x"+btStakingInfo.VStakingAddr.String())

	return []byte(code)
}

func MintNewWakandaPass(
	t *testing.T, b *emulator.Blockchain, nftAddr flow.Address,
	userAddr flow.Address, userSigner crypto.Signer,
	bpAddr flow.Address, bpSigner crypto.Signer) {

	tx := flow.NewTransaction().
		SetScript(bpSetupWakandaPassCollectionTransaction(bpAddr, nftAddr)).
		SetGasLimit(100).
		SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(userAddr)

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, userAddr},
		[]crypto.Signer{b.ServiceKey().Signer(), userSigner},
		false,
	)

	tx = flow.NewTransaction().
		SetScript(bpMintWakandaPassTransaction(bpAddr, nftAddr)).
		SetGasLimit(100).
		SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(bpAddr)
	_ = tx.AddArgument(cadence.NewAddress(userAddr))

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, bpAddr},
		[]crypto.Signer{b.ServiceKey().Signer(), bpSigner},
		false,
	)
}

func loadNonFungibleToken() []byte {
	return nft_contracts.NonFungibleToken()
}

func bpMintWakandaPassTransaction(bpAddr flow.Address, nftAddr flow.Address) []byte {
	code := string(readFile(wpMintWakandaPassPath))

	code = strings.ReplaceAll(code, "\"../../../contracts/flow/token/NonFungibleToken.cdc\"", "0x"+nftAddr.String())
	code = strings.ReplaceAll(code, "\"../../../contracts/flow/token/WakandaPass.cdc\"", "0x"+bpAddr.String())

	return []byte(code)
}

func bpSetupWakandaPassCollectionTransaction(bpAddr flow.Address, nftAddr flow.Address) []byte {
	code := string(readFile(wpSetupWakandaPassCollectionPath))

	code = strings.ReplaceAll(code, "\"../../contracts/flow/token/NonFungibleToken.cdc\"", "0x"+nftAddr.String())
	code = strings.ReplaceAll(code, "\"../../contracts/flow/token/WakandaPass.cdc\"", "0x"+bpAddr.String())

	return []byte(code)
}

func bpGetPropertyScript(filename string, btAddr flow.Address) []byte {
	return []byte(strings.ReplaceAll(
		string(readFile(filename)),
		"\"../../contracts/flow/token/WakandaPass.cdc\"",
		"0x"+btAddr.String(),
	))
}

func bpGetWakandaPassVaultBalanceScript(bpAddr flow.Address, nftAddr flow.Address) []byte {
	code := string(readFile(wpGetWakandaPassVaultBalancePath))

	code = strings.ReplaceAll(code, "\"../../contracts/flow/token/NonFungibleToken.cdc\"", "0x"+nftAddr.String())
	code = strings.ReplaceAll(code, "\"../../contracts/flow/token/WakandaPass.cdc\"", "0x"+bpAddr.String())

	return []byte(code)
}
