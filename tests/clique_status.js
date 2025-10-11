const axios = require('axios');
const RPC = process.env.RPC || 'http://127.0.0.1:8545';
(async()=>{
  const { data } = await axios.post(RPC, { jsonrpc:'2.0', id:1, method:'clique_getSignerMetrics', params:[] });
  console.log(JSON.stringify(data, null, 2));
})();
