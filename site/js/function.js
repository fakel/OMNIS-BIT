var eth;
var user_address;

window.addEventListener('load', async () => {
    // Modern dapp browsers...
    if (window.ethereum) {
        window.web3 = new Web3(ethereum);
        try {
            // Request account access if needed
            await ethereum.enable();

            eth = new Eth(web3.currentProvider);

            web3.version.getNetwork((err, netId) => {

                if (netId == 3) {
                    alert('Connected to Ropsten');
                    window.usingNet = "3";
                    main();
                } else if (netId == 1) {
                    alert('Connected to Main net');
                    window.usingNet = "1";
                    main();
                } else {
                    alert("Connect to Main net or Ropsten for testing")
                }

            });

        } catch (error) {
            console.log(error);
        }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
        window.web3 = new Web3(web3.currentProvider);

        eth = new Eth(web3.currentProvider);

        web3.version.getNetwork((err, netId) => {

            if (netId == 3) {
                alert('Connected to Ropsten');
                window.usingNet = "3";
            } else if (netId == 1) {
                alert('Connected to Main net');
                window.usingNet = "1";
            } else {
                alert("Connect to Main net or Ropsten for testing")
            }
        });

    }
    // Non-dapp browsers...
    else {
        alert('Non-Ethereum enabled browser detected. You should consider trying MetaMask!');
    }
});

function main() {

    setInterval(function () {

        user_address = web3.eth.accounts[0];

        if (typeof user_address === 'undefined') {
            return alert('You need to log in MetaMask to use site features.');
        }

    }, 5000);

    if (window.usingNet == 3) {
        window.omnis = ''; //Ropsten address of contract
    } else {
        window.omnis = ''; //Main net address of contract
    }

    const omnisABI = [{
            "constant": false,
            "inputs": [],
            "name": "checkIfFundingCompleteOrExpired",
            "outputs": [],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": false,
            "inputs": [],
            "name": "claimReferral",
            "outputs": [],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": false,
            "inputs": [{
                "name": "referralAddress",
                "type": "address"
            }],
            "name": "contribute",
            "outputs": [],
            "payable": true,
            "stateMutability": "payable",
            "type": "function"
        },
        {
            "constant": false,
            "inputs": [{
                "name": "pollResult",
                "type": "bool"
            }],
            "name": "extension",
            "outputs": [],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": false,
            "inputs": [],
            "name": "finished",
            "outputs": [],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "anonymous": false,
            "inputs": [{
                    "indexed": false,
                    "name": "_addr",
                    "type": "address"
                },
                {
                    "indexed": false,
                    "name": "_amount",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "name": "_currentTotal",
                    "type": "uint256"
                }
            ],
            "name": "LogFundingReceived",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [{
                "indexed": false,
                "name": "_beneficiaryAddress",
                "type": "address"
            }],
            "name": "LogBeneficiaryPaid",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [{
                "indexed": false,
                "name": "_totalRaised",
                "type": "uint256"
            }],
            "name": "LogFundingSuccessful",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [{
                    "indexed": false,
                    "name": "_creator",
                    "type": "address"
                },
                {
                    "indexed": false,
                    "name": "_url",
                    "type": "string"
                },
                {
                    "indexed": false,
                    "name": "_ICOdeadline",
                    "type": "uint256"
                }
            ],
            "name": "LogFunderInitialized",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [{
                    "indexed": false,
                    "name": "_addr",
                    "type": "address"
                },
                {
                    "indexed": false,
                    "name": "_amount",
                    "type": "uint256"
                }
            ],
            "name": "LogContributorsPayout",
            "type": "event"
        },
        {
            "constant": false,
            "inputs": [],
            "name": "retrieveTokens",
            "outputs": [],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": false,
            "inputs": [{
                "name": "value",
                "type": "uint8"
            }],
            "name": "setState",
            "outputs": [],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "payable": true,
            "stateMutability": "payable",
            "type": "fallback"
        },
        {
            "inputs": [{
                    "name": "_addressOfTokenUsedAsReward",
                    "type": "address"
                },
                {
                    "name": "_beneficiary",
                    "type": "address"
                }
            ],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "constructor"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "beneficiary",
            "outputs": [{
                "name": "",
                "type": "address"
            }],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "campaignUrl",
            "outputs": [{
                "name": "",
                "type": "string"
            }],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "completedAt",
            "outputs": [{
                "name": "",
                "type": "uint256"
            }],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "creator",
            "outputs": [{
                "name": "",
                "type": "address"
            }],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "ICOdeadline",
            "outputs": [{
                "name": "",
                "type": "uint256"
            }],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "ICOLimit",
            "outputs": [{
                "name": "",
                "type": "uint256"
            }],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "presaleLimit",
            "outputs": [{
                "name": "",
                "type": "uint256"
            }],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [{
                "name": "",
                "type": "uint256"
            }],
            "name": "rates",
            "outputs": [{
                "name": "",
                "type": "uint256"
            }],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [{
                "name": "",
                "type": "address"
            }],
            "name": "referralBalance",
            "outputs": [{
                "name": "",
                "type": "uint256"
            }],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "startTime",
            "outputs": [{
                "name": "",
                "type": "uint256"
            }],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "state",
            "outputs": [{
                "name": "",
                "type": "uint8"
            }],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "tokenReward",
            "outputs": [{
                "name": "",
                "type": "address"
            }],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "totalDistributed",
            "outputs": [{
                "name": "",
                "type": "uint256"
            }],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "totalRaised",
            "outputs": [{
                "name": "",
                "type": "uint256"
            }],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "totalReferral",
            "outputs": [{
                "name": "",
                "type": "uint256"
            }],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "version",
            "outputs": [{
                "name": "",
                "type": "string"
            }],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        }
    ]

    window.omnisContract = eth.contract(omnisABI).at(omnis);

    eth.gasPrice((err, res) => {
        window.gasprice = (new Eth.BN(res)).toNumber();
    });

}

function purchase() {

    var user_address = web3.eth.accounts[0];
    var amount = Eth.toWei(document.getElementById('contAmount').value, "ether");
    var referral = document.getElementById('refAdd').value;

    if (referral == undefined || !Eth.isAddress(referral)) {
        alert("No valid referral address detected")
        referral = "0x0000000000000000000000000000000000000000";
    }

    omnisContract.contribute(referral, {
            from: user_address,
            value: amount,
            gasPrice: gasprice
        })
        .then(txHash => eth.getTransactionSuccess(txHash))
        .then(receipt => {
            alert('Tx Sent')
        })
        .catch((err) => {
            alert(err);
        })

}