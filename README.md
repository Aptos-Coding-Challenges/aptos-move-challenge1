# Challenge #1: My First Aptos NFT 🎨

Build out the missing logic inside `contract::my_first_nft` (see `sources/my_first_nft.move`)
to mint and burn object-based NFTs using Aptos Token Objects. All behaviors are enforced by
`tests/my_first_nft_tests.move`, and helper scripts verify that those tests have not been
altered while you work on the module.

## Repository Layout

- `Move.toml` – package metadata plus pinned `aptos-framework` dependencies.
- `sources/my_first_nft.move` – starter contract with complete type definitions, challenge
  context comments, and `abort 0` function bodies for you to replace.
- `tests/my_first_nft_tests.move` – canonical test suite; **do not modify this file**.
- `verify.sh` / `verify.ps1` – automation that checks the test hash and then runs
  `aptos move test`.

## Checkpoint 1: 📦 Environment Setup

Before you begin, install the following tools:

1. [Install Aptos CLI](https://aptos.dev/build/cli)

Then fork and clone the challenge repo to your computer and install dependencies:
1. [Fork this repository.](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo)
2. Clone the repository
```bash
cd [DIRECTORY_OF_YOUR_CHOICE]
git clone [FORKED_REPO_URL]
```
3. Open the cloned repo in [Cursor IDE](https://cursor.com/) or [VSCode IDE](https://code.visualstudio.com/)
4. Install the `Move on Aptos` extension
![alt text](</public/move-on-aptos.png>)

## Checkpoint 2: 🎲 Solve the Challenge!

Go to the `sources/my_first_nft.move` file to solve the challenge.

### What You Must Implement

Inside `sources/my_first_nft.move`:

1. `mint` must read the cached collection data, create a numbered token, persist the
   relevant token references plus `CustomMetadata`, emit `MintEvent`, and return the
   new object.
2. `burn` must restrict execution to the owner, emit `BurnEvent`, clean up on-chain
   state, and call `token::burn` using the cached burn ref.
3. `get_custom_metadata` should return the stored metadata for an object address.

Initialization (`init_module`) and helper getters are provided; focus on wiring the mint
and burn flows so that the unit tests pass.

**📚 Here are some helpful resources if you are struggling!**

- [Your First Move Module: How to compile, test, deploy Move Modules](https://aptos.dev/build/guides/first-move-module)
- [Aptos Move Documentation](https://aptos.dev/build/smart-contracts)

## Checkpoint 3: ✅ Validate Your Work!

### Test Integrity Guard

The scripts compare the SHA-256 hash of `tests/my_first_nft_tests.move` against the
expected value (`def98fcc65656ccee12f4a516dff1790b8ba0fc42597385388a2e08962154022`).
If the hash differs, validation stops immediately. This guarantees that every solution
is judged against the same tests.

### How to Validate Your Work

Linux/macOS:

```bash
./verify.sh [additional aptos move test args]
```

Windows (PowerShell 7+):

```powershell
pwsh -File verify.ps1 [-AptosArgs @('--filter','foo')]
```

Both scripts:

1. Ensure the test file hash matches the expected value.
2. Run `aptos move test` (plus any extra arguments you pass through).

You can still run `aptos move test` manually, but the scripts are the easiest way to
prove your solution meets the challenge requirements.

### Tips

- The constants at the top of `sources/my_first_nft.move` can be tweaked to personalize
  metadata, but avoid changing the public API.
- Read through the tests to understand the order of operations the graders expect.
- The Aptos CLI must be available on your PATH for both the scripts and manual runs.

## Checkpoint 4: 💯 Submit your answer 

1. After successfully passing the tests, push your code to your forked Github repo and [make a PR to the original repo.](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork) 
2. Inside the PR include:
  - Screenshot of your terminal showing the result of running the test script.