const { ethers } = require("ethers");
(async ()=>{
  const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");
  const wallet = new ethers.Wallet(process.env.PRIVKEY, provider);
  const to = "0x000000000000000000000000000000000000dEaD";
  const tx = await wallet.sendTransaction({ to, value: ethers.parseEther("0.00001") });
  console.log("sent:", tx.hash);
  await tx.wait();
  console.log("confirmed");
})();
