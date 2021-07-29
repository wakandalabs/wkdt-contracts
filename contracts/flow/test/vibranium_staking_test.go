package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
	emulator "github.com/onflow/flow-emulator"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
	"github.com/onflow/flow-go-sdk/templates"
	"github.com/onflow/flow-go-sdk/test"
	"github.com/stretchr/testify/assert"
)

type TestVibraniumStakingContractsInfo struct {
	FTAddr          flow.Address
	VAddr          flow.Address
	VSigner        crypto.Signer
	VStakingAddr   flow.Address
	VStakingSigner crypto.Signer
}

func VibraniumStakingDeployContract(b *emulator.Blockchain, t *testing.T) TestVibraniumStakingContractsInfo {
	accountKeys := test.AccountKeyGenerator()

	fungibleAddr, vibraniumAddr, vibraniumSigner := VibraniumDeployContract(b, t)

	vibraniumStakingAccountKey, vibraniumStakingSigner := accountKeys.NewWithSigner()
	vibraniumStakingCode := loadVibraniumStaking(fungibleAddr, vibraniumAddr)

	vibraniumStakingAddr, err := b.CreateAccount(
		[]*flow.AccountKey{vibraniumStakingAccountKey},
		[]templates.Contract{{
			Name:   "VibraniumStaking",
			Source: string(vibraniumStakingCode),
		}},
	)
	assert.NoError(t, err)

	_, err = b.CommitBlock()
	assert.NoError(t, err)

	// oneUFix64, _ := cadence.NewUFix64("1.0")
	// tx, err := addAccountContractWithArgs(
	// 	vibraniumStakingAddr,
	// 	templates.Contract{
	// 		Name:   "VibraniumStaking",
	// 		Source: string(vibraniumStakingCode),
	// 	},
	// 	[]cadence.Value{oneUFix64},
	// )
	// assert.NoError(t, err)

	// tx = tx.
	// 	SetGasLimit(100).
	// 	SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
	// 	SetPayer(b.ServiceKey().Address)

	// signAndSubmit(
	// 	t, b, tx,
	// 	[]flow.Address{b.ServiceKey().Address, vibraniumStakingAddr},
	// 	[]crypto.Signer{b.ServiceKey().Signer(), vibraniumStakingSigner},
	// 	false,
	// )

	return TestVibraniumStakingContractsInfo{
		FTAddr:          fungibleAddr,
		VAddr:          vibraniumAddr,
		VSigner:        vibraniumSigner,
		VStakingAddr:   vibraniumStakingAddr,
		VStakingSigner: vibraniumStakingSigner,
	}
}

func addAccountContractWithArgs(
	signerAddr flow.Address,
	contract templates.Contract,
	args []cadence.Value,
) (*flow.Transaction, error) {
	const addAccountContractTemplate = `
	transaction(name: String, code: String %s) {
		prepare(signer: AuthAccount) {
			signer.contracts.add(name: name, code: code.decodeHex() %s)
		}
	}`

	cadenceName := cadence.NewString(contract.Name)
	cadenceCode := cadence.NewString(contract.SourceHex())

	tx := flow.NewTransaction().
		AddRawArgument(jsoncdc.MustEncode(cadenceName)).
		AddRawArgument(jsoncdc.MustEncode(cadenceCode)).
		AddAuthorizer(signerAddr)

	for _, arg := range args {
		arg.Type().ID()
		tx.AddRawArgument(jsoncdc.MustEncode(arg))
	}

	txArgs, addArgs := "", ""
	for i, arg := range args {
		txArgs += fmt.Sprintf(",arg%d:%s", i, arg.Type().ID())
		addArgs += fmt.Sprintf(",arg%d", i)
	}

	script := fmt.Sprintf(addAccountContractTemplate, txArgs, addArgs)
	tx.SetScript([]byte(script))

	return tx, nil
}

func loadVibraniumStaking(fungibleAddr flow.Address, vibraniumAddr flow.Address) []byte {
	code := string(readFile(vibraniumStakingPath))

	code = strings.ReplaceAll(code, "\"../token/FungibleToken.cdc\"", "0x"+fungibleAddr.String())
	code = strings.ReplaceAll(code, "\"../token/Vibranium.cdc\"", "0x"+vibraniumAddr.String())

	return []byte(code)
}