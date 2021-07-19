#!/bin/sh

redBG=$(tput setab 1)
reset=$(tput sgr0)
action=$(echo "${redBG}[ACTION]${reset}")

# Step 0. We change the directory to root and stop dfx (if running).
echo
echo "${action} Stopping DFX"
echo
cd ..
dfx stop

# Step 1. We start the dfx service
echo
echo "${action} Starting DFX"
echo
dfx start --background --clean

# Step 2. Let's deploy our canisters on IC.
echo
echo "${action} Deploying Dank and Piggy Bank on IC"
echo
dfx deploy

# Step 3. We get Piggy Bank's and our balance.
echo
echo "${action} Getting the balances of Piggy Bank and our Dank account"
echo
piggyBalance=$(dfx canister call piggy-bank balance)
dankBalance=$(dfx canister call dank balance "(null)")
echo "Piggy Bank's balance: $piggyBalance"
echo "Our Dank account's balance: $dankBalance"

# Step 4. We deposit some cycles to our Dank account from Piggy-Bank.
echo
echo "${action} Depositing 5000 cycles to our Dank account from Piggy Bank"
echo
dankID=$(dfx canister id dank)
dfx canister call piggy-bank perform_deposit "(record { canister= principal \"$dankID\"; account=null; cycles=5000 })"

echo
piggyBalance=$(dfx canister call piggy-bank balance)
dankBalance=$(dfx canister call dank balance "(null)")
echo "Piggy Bank's new balance: $piggyBalance"
echo "Our Dank account's balance: $dankBalance"

# Step 5. We withdraw some cycles from Dank.
echo
echo "${action} Withdrawing 2000 cycles from Dank to Piggy Bank"
echo
piggyID=$(dfx canister id piggy-bank)
dfx canister call dank withdraw "(record { canister_id= principal \"$piggyID\"; amount= 2000})"

echo
piggyBalance=$(dfx canister call piggy-bank balance)
dankBalance=$(dfx canister call dank balance "(null)")
echo "Piggy Bank's new balance: $piggyBalance"
echo "Our Dank account's balance: $dankBalance"

# Step 6. We create a new identity and transfer some cycles to it.
echo
echo "${action} Creating a new identity named steve and transfering 1000 cycles to it."
echo
dfx identity new steve || true
steveID=$(dfx --identity steve identity get-principal)
dfx canister call dank transfer "(record { to= principal \"$steveID\"; amount= 1000 })"

echo
steveBalance=$(dfx --identity steve canister call dank balance "(null)")
dankBalance=$(dfx canister call dank balance "(null)")
echo "Steve's new balance: $steveBalance"
echo "Our Dank account's balance: $dankBalance"


# Now that we're done let's stop the service.
echo
echo "${action} Stopping the service"
echo
dfx stop