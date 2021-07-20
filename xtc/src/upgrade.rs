use crate::history::{HistoryBuffer, Transaction};
use crate::ledger::Ledger;
use crate::management;
use ic_cdk::export::candid::{CandidType, Deserialize, Principal};
use ic_cdk::*;
use ic_cdk_macros::*;

#[derive(CandidType, Deserialize)]
struct StableStorage {
    ledger: Vec<(Principal, u64)>,
    history: Vec<Transaction>,
    controller: Principal,
}

#[pre_upgrade]
pub fn pre_upgrade() {
    let ledger = storage::get_mut::<Ledger>().archive();
    let history = storage::get_mut::<HistoryBuffer>().archive();
    let controller = management::Controller::get_principal();

    let stable = StableStorage {
        ledger,
        history,
        controller,
    };

    match storage::stable_save((stable,)) {
        Ok(_) => (),
        Err(candid_err) => {
            trap(&format!(
                "An error occurred when saving to stable memory (pre_upgrade): {:?}",
                candid_err
            ));
        }
    };
}

#[post_upgrade]
pub fn post_upgrade() {
    if let Ok((stable,)) = storage::stable_restore::<(StableStorage,)>() {
        storage::get_mut::<Ledger>().load(stable.ledger);
        storage::get_mut::<HistoryBuffer>().load(stable.history);
        management::Controller::load(stable.controller);
    }
}