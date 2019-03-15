# OMNIS-BIT
OMNIS-BIT additional features development

## About js web purchase function

To use the script you will require to import it on your site, also it's required to import the [ethjs](https://github.com/ethjs) library

```
<script type="text/javascript" src="https://cdn.jsdelivr.net/npm/ethjs@0.3.4/dist/ethjs.min.js"></script>
```

To make a purchase from your site to the ICO contract you must configure the script:

* **window.omnis:** address of your contract on the corresponding network

## Site script use

When you make a call to the ```purchase()``` function on the script, it will require from your interface two values:

* **amount:** amount in ethers, taken from html id tag ```contAmount```
* **referral:** Address of referral wallet, with 0x prefix, taken from html id tag ```refAdd```

Once you call this function, a prompt will show from Metamask, there you can review the transaction.