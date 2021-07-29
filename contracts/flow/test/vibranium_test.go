package test

import (
	"strings"
	"testing"

	"github.com/onflow/cadence"
	emulator "github.com/onflow/flow-emulator"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
	"github.com/onflow/flow-go-sdk/templates"
	"github.com/onflow/flow-go-sdk/test"
	"github.com/stretchr/testify/assert"

	ft_contracts "github.com/onflow/flow-ft/lib/go/contracts"
)

const (
	btSetupVibraniumMinterForStakingPath = projectRootPath + "/transactions/token/admin/setupVibraniumMinterForStaking.cdc"
)

func VibraniumDeployContract(b *emulator.Blockchain, t *testing.T) (flow.Address, flow.Address, crypto.Signer) {
	accountKeys := test.AccountKeyGenerator()

	// Should be able to deploy a contract as a new account with no keys.
	fungibleTokenCode := loadFungibleToken()
	fungibleAddr, err := b.CreateAccount(
		[]*flow.AccountKey{},
		[]templates.Contract{{
			Name:   "FungibleToken",
			Source: string(fungibleTokenCode),
		}},
	)
	assert.NoError(t, err)

	_, err = b.CommitBlock()
	assert.NoError(t, err)

	vibraniumAccountKey, vibraniumSigner := accountKeys.NewWithSigner()
	vibraniumCode := loadVibranium(fungibleAddr)

	vibraniumAddr, err := b.CreateAccount(
		[]*flow.AccountKey{vibraniumAccountKey},
		[]templates.Contract{{
			Name:   "Vibranium",
			Source: string(vibraniumCode),
		}},
	)
	assert.NoError(t, err)

	_, err = b.CommitBlock()
	assert.NoError(t, err)

	return fungibleAddr, vibraniumAddr, vibraniumSigner
}

func loadFungibleToken() []byte {
	return ft_contracts.FungibleToken()
}

func loadVibranium(fungibleAddr flow.Address) []byte {
	return []byte(strings.ReplaceAll(
		string(readFile(vibraniumPath)),
		"\"./FungibleToken.cdc\"",
		"0x"+fungibleAddr.String(),
	))
}

func btSetupVibraniumMinterForStakingTransaction(btAddr flow.Address, ftAddr flow.Address) []byte {
	code := string(readFile(btSetupVibraniumMinterForStakingPath))

	code = strings.ReplaceAll(code, "\"../../../contracts/flow/token/FungibleToken.cdc\"", "0x"+ftAddr.String())
	code = strings.ReplaceAll(code, "\"../../../contracts/flow/token/Vibranium.cdc\"", "0x"+btAddr.String())

	return []byte(code)
}

func SetupVibraniumMinterForStaking(
	t *testing.T, b *emulator.Blockchain,
	ftAddr flow.Address, amount cadence.Value,
	btAddr flow.Address, btSigner crypto.Signer,
	minterAddr flow.Address, minterSigner crypto.Signer) {

	tx := flow.NewTransaction().
		SetScript(btSetupVibraniumMinterForStakingTransaction(btAddr, ftAddr)).
		SetGasLimit(100).
		SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(btAddr).
		AddAuthorizer(minterAddr)

	_ = tx.AddArgument(amount)

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, btAddr, minterAddr},
		[]crypto.Signer{b.ServiceKey().Signer(), btSigner, minterSigner},
		false,
	)
}