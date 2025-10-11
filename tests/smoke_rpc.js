const axios = require('axios');
const RPC = process.env.RPC || 'http://127.0.0.1:8545';
async function j(method, params=[]) {
  const { data } = await axios.post(RPC, { jsonrpc:'2.0', id:1, method, params });
  return data.result;
}
(async()=>{
  console.log('chainId=', await j('eth_chainId'));
  console.log('blockNumber=', await j('eth_blockNumber'));
  console.log('coinbase=', await j('eth_coinbase'));
})();
