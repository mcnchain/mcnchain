
var VALIDATORS = [
  "0x014B5831d8a4449Bd8bEbef4540B865a4563Cbd0",
  "0x57d5937C6942B5f59c44c7400834A4946C397734",
  "0x7e96EdCA7866403739E18Fd91582f9A86D4b085a",
  "0xfE4800cA5a48670cc5f591a51F517BA8F682D4Ae"
];
var VALIDATOR_WEIGHTS = {}; 


var COINBASE = eth.coinbase; if (!COINBASE) throw "No etherbase set";
var EXCLUDE_SENDERS = (function(){
  var s = {};
  s[COINBASE.toLowerCase()] = true; 
  
  return s;
})();


var BURN_ADDR = "0x000000000000000000000000000000000000dEaD";
var DEVS_ADDR = "0xbDc67FFFb4ec9e315203d9F70b63E0d911908044";
var ECO_ADDR  = "0xb8f9505cC43BF1F20945E2F21d40c36a51c84322";


var SHARES = { validators: 4000, burn: 3000, devs: 2000, eco: 1000 };
if (SHARES.validators + SHARES.burn + SHARES.devs + SHARES.eco !== 10000) {
  throw "Shares must sum to 10000";
}

// ==== РЕЖИМ УЧЁТА ГАЗА ====
// 'total' — делим ВСЮ комиссию отправителей: egp * gasUsed.
// 'miner' — делим ТОЛЬКО доход валидатора (tip): (egp - baseFee) * gasUsed.
var GAS_SHARE_MODE = 'total';

// ==== ПРОЧЕЕ ====
var MCN  = "ether";
var GWEI = "gwei";

// Порог/газ/лимиты
var MIN_PAYOUT = web3.toWei(0.000001, MCN); // минимальный пул для рассылки
var GAS_LIMIT  = 21000;
var PRIO_GWEI  = 1;                         // prio для наших выплат
var MAX_CHUNK  = null;                      // лимит одной выплаты (или null)

// ==== HELPERS ====
function bn(v){ return web3.toBigNumber(v); }
function asWeiHex(xBn){ var vv = bn(xBn); if (vv.lt(0)) vv = bn(0); return "0x"+vv.toString(16); }
function fromWeiStr(x){ return web3.fromWei(x, MCN).toString(); }

function currentFees(){
  var b = eth.getBlock("latest");
  if (b && b.baseFeePerGas){
    var base = bn(b.baseFeePerGas);
    var prio = bn(web3.toWei(PRIO_GWEI, GWEI));
    var max  = base.mul(2).add(prio);
    return { mode:"eip1559", base: base, prio: prio, max: max };
  } else {
    var gp = eth.gasPrice; if(!gp || gp.eq(0)) gp = bn(web3.toWei(1, GWEI));
    return { mode:"legacy", gasPrice: gp };
  }
}

function calcFeeReserve(n){
  var f = currentFees();
  return (f.mode === "eip1559" ? f.max.mul(GAS_LIMIT).mul(n) : f.gasPrice.mul(GAS_LIMIT).mul(n));
}

function availableToSendLeft(portionsLeft){
  var bal = bn(eth.getBalance(COINBASE));
  var reserve = calcFeeReserve(portionsLeft);
  var avail = bal.sub(reserve);
  return avail.gt(0) ? avail : bn(0);
}

function cappedPortion(wantedWei, portionsLeft){
  var want = bn(wantedWei);
  var can  = availableToSendLeft(portionsLeft);
  return want.gt(can) ? can : want;
}

function safeSend(from, to, valueWei){
  var v = bn(valueWei);
  if (!to || v.lte(0)) return null;
  try {
    var f = currentFees();
    var tx = { from: from, to: to, value: asWeiHex(v), gas: GAS_LIMIT };
    if (f.mode === "eip1559"){ tx.maxPriorityFeePerGas = f.prio; tx.maxFeePerGas = f.max; }
    else { tx.gasPrice = f.gasPrice; }
    return eth.sendTransaction(tx);
  } catch(e){
    console.log("send failed:", to, fromWeiStr(v), "err:", e);
    return null;
  }
}

function sumWeights(){
  if (!VALIDATORS || VALIDATORS.length===0) return 0;
  var tot=0;
  for (var i=0;i<VALIDATORS.length;i++){
    var w = VALIDATOR_WEIGHTS[VALIDATORS[i]];
    if (typeof w!=="number" || w<=0) w=1;
    tot+=w;
  }
  return tot;
}

function clampMaxChunk(x){
  if (!MAX_CHUNK) return bn(x);
  var v = bn(x);
  return v.gt(MAX_CHUNK) ? bn(MAX_CHUNK) : v;
}

function logPre(pool){
  var f = currentFees();
  var info = (f.mode==="eip1559")
    ? ("1559 base="+web3.fromWei(f.base,"gwei")+" prio="+web3.fromWei(f.prio,"gwei")+" max="+web3.fromWei(f.max,"gwei")+" gwei")
    : ("legacy gasPrice="+web3.fromWei(f.gasPrice,"gwei")+" gwei");
  console.log("[split:pre]",
    "blk=", eth.blockNumber,
    "mode=", info,
    "bal=", fromWeiStr(eth.getBalance(COINBASE)),
    "feePool=", fromWeiStr(pool),
    "min=", fromWeiStr(MIN_PAYOUT)
  );
}

// ==== УЧЁТ ГАЗА ====
if (typeof _feePool          === "undefined") _feePool          = bn(0);
if (typeof _lastProcessedBlk === "undefined") _lastProcessedBlk = eth.blockNumber;
if (typeof _isSplitBusy      === "undefined") _isSplitBusy      = false; // ЛОК

// Комиссия транзакции по выбранному режиму
// ВАЖНО: игнорим tx, у которых from ∈ EXCLUDE_SENDERS (например, COINBASE)
function feeOfTx(tx, r, b){
  if (!tx || !r) return bn(0);
  var from = (tx.from || "").toLowerCase();
  if (EXCLUDE_SENDERS[from]) return bn(0); // ← вот это главное условие

  var gasUsed = bn(r.gasUsed || 0);
  if (gasUsed.eq(0)) return bn(0);

  var egp = r.effectiveGasPrice != null ? bn(r.effectiveGasPrice) : (tx.gasPrice ? bn(tx.gasPrice) : bn(0));

  if (GAS_SHARE_MODE === 'miner'){
    var base = (b && b.baseFeePerGas != null) ? bn(b.baseFeePerGas) : null;
    if (base){
      var tip = egp.sub(base); if (tip.lt(0)) tip = bn(0);
      return tip.mul(gasUsed);
    } else {
      return egp.mul(gasUsed); // legacy — всё майнеру
    }
  }
  return egp.mul(gasUsed); // total
}

// Суммируем по ВСЕМ транзакциям блока
function collectBlockGasTotal(n){
  var b = eth.getBlock(n, true);
  if (!b || !b.transactions || b.transactions.length===0) return bn(0);

  var total = bn(0);
  for (var i=0;i<b.transactions.length;i++){
    var tx = b.transactions[i];
    var r = null;
    try { r = eth.getTransactionReceipt(tx.hash); } catch(e){ r=null; }
    if (!r) continue;

    var fee = feeOfTx(tx, r, b);
    if (fee.gt(0)) total = total.add(fee);
  }
  return total;
}

function processBlocksAndDistribute(){
  if (_isSplitBusy) return;
  _isSplitBusy = true;
  try {
    var head = eth.blockNumber; if (head==null) return;

    if (_lastProcessedBlk == null) _lastProcessedBlk = head - 1;
    if (head <= _lastProcessedBlk) return; // guard

    var start = _lastProcessedBlk + 1;
    if (start < 0) start = 0;

    var added = bn(0);
    for (var n=start; n<=head; n++){
      var f = collectBlockGasTotal(n);
      if (f.gt(0)) added = added.add(f);
    }
    if (added.gt(0)){
      _feePool = _feePool.add(added);
      console.log("[gas:add] +", fromWeiStr(added), "pool=", fromWeiStr(_feePool), "range=", start, "…", head);
    }
    _lastProcessedBlk = head;

    logPre(_feePool);
    if (_feePool.lt(MIN_PAYOUT)) return;

    // Рассылка возможна только если есть газ на сами выплаты
    var transfersCount = (VALIDATORS ? VALIDATORS.length : 0) + 3;
    var feeReserve = calcFeeReserve(transfersCount);
    var bal = bn(eth.getBalance(COINBASE));
    if (bal.lte(feeReserve)){
      console.log("[skip] balance <= feeReserve (need gas)");
      return;
    }

    var maxSpendByGas = bal.sub(feeReserve);
    var spendNow = _feePool.gt(maxSpendByGas) ? maxSpendByGas : _feePool;
    if (spendNow.lte(0)){
      console.log("[skip] spendNow <= 0 after gas reserve");
      return;
    }

    var distributable = spendNow;

    var toValidatorsTotal = bn(distributable.mul(SHARES.validators).div(10000));
    var toBurn            = bn(distributable.mul(SHARES.burn).div(10000));
    var toDevs            = bn(distributable.mul(SHARES.devs).div(10000));
    var toEco             = bn(distributable.sub(toValidatorsTotal).sub(toBurn).sub(toDevs));

    console.log("[split]",
      "distribute=", fromWeiStr(distributable),
      "validators=", fromWeiStr(toValidatorsTotal),
      "burn=",       fromWeiStr(toBurn),
      "devs=",       fromWeiStr(toDevs),
      "eco=",        fromWeiStr(toEco)
    );

    var portionsRemaining = transfersCount;

    // == валидаторы ==
    if (VALIDATORS && VALIDATORS.length>0 && toValidatorsTotal.gt(0)){
      var totalW = sumWeights(); if (totalW===0) totalW = VALIDATORS.length;
      var sentSum = bn(0);
      for (var i=0;i<VALIDATORS.length;i++){
        var addr = VALIDATORS[i];
        var w = VALIDATOR_WEIGHTS[addr]; if (typeof w!=="number" || w<=0) w=1;

        var portion = (i<VALIDATORS.length-1) ? toValidatorsTotal.mul(w).div(totalW) : toValidatorsTotal.sub(sentSum);
        portion = clampMaxChunk(portion);
        var capped = cappedPortion(portion, (VALIDATORS.length - i - 1) + 3);
        if (capped.lte(0)){ console.log("→ val", i, addr, "skip"); portionsRemaining--; continue; }

        console.log("→ val.pre", i, addr,
          "want=", fromWeiStr(portion),
          "cap=",  fromWeiStr(capped),
          "bal=",  fromWeiStr(eth.getBalance(COINBASE)),
          "leftForFees=", fromWeiStr(calcFeeReserve((VALIDATORS.length - i - 1) + 3))
        );

        var tx = safeSend(COINBASE, addr, capped);
        console.log("→ val", i, addr, fromWeiStr(capped), "tx:", tx);
        if (tx) sentSum = sentSum.add(capped);
        portionsRemaining--;
      }
    }

    // == burn / devs / eco ==
    var burnAmt = clampMaxChunk(toBurn);
    burnAmt = cappedPortion(burnAmt, portionsRemaining - 1);
    var txBurn = burnAmt.gt(0) ? safeSend(COINBASE, BURN_ADDR, burnAmt) : null;
    console.log("→ burn.pre want=", fromWeiStr(toBurn), "cap=", fromWeiStr(burnAmt),
                "bal=", fromWeiStr(eth.getBalance(COINBASE)));
    console.log("→ burn:", txBurn);
    portionsRemaining--;

    var devAmt = clampMaxChunk(toDevs);
    devAmt = cappedPortion(devAmt, portionsRemaining - 1);
    var txDev = devAmt.gt(0) ? safeSend(COINBASE, DEVS_ADDR, devAmt) : null;
    console.log("→ devs.pre want=", fromWeiStr(toDevs), "cap=", fromWeiStr(devAmt),
                "bal=", fromWeiStr(eth.getBalance(COINBASE)));
    console.log("→ devs:", txDev);
    portionsRemaining--;

    var ecoAmt = clampMaxChunk(toEco);
    ecoAmt = cappedPortion(ecoAmt, portionsRemaining);
    var txEco = ecoAmt.gt(0) ? safeSend(COINBASE, ECO_ADDR, ecoAmt) : null;
    console.log("→ eco.pre want=", fromWeiStr(toEco), "cap=", fromWeiStr(ecoAmt),
                "bal=", fromWeiStr(eth.getBalance(COINBASE)));
    console.log("→ eco:", txEco);

    // списываем ровно то, что разослали
    _feePool = _feePool.sub(distributable);
    if (_feePool.lt(0)) _feePool = bn(0);

    console.log("[split:post] feePool=", fromWeiStr(_feePool), "newBal=", fromWeiStr(eth.getBalance(COINBASE)));
  } finally {
    _isSplitBusy = false;
  }
}

if (typeof _splitFilter === "undefined"){
  _splitFilter = eth.filter("latest");
  _splitFilter.watch(function(){ try { processBlocksAndDistribute(); } catch(e){ console.log("distribute error:", e); } });
  console.log("split-all-gas v3.4: using filter('latest') trigger");
}

this.trigger = function(){ try { processBlocksAndDistribute(); } catch(e){ console.log(e); } };

console.log("split-all-gas loaded. mode=", GAS_SHARE_MODE, "validators:", VALIDATORS.length, "exclude", Object.keys(EXCLUDE_SENDERS));