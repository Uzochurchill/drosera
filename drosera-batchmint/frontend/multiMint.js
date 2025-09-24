
import { ethers } from "ethers";

async function multiMint(times) {
  if (!window.ethereum) throw new Error("No wallet found");

  const provider = new ethers.BrowserProvider(window.ethereum);
  const signer = await provider.getSigner();

  const batchMinterAddress = "0xYourDeployedBatchMinter"; // replace with deployed address
  const abi = [
    "function batchMint(uint256 times) external"
  ];

  const contract = new ethers.Contract(batchMinterAddress, abi, signer);
  const tx = await contract.batchMint(times);
  console.log("Transaction hash:", tx.hash);
}

export default multiMint;
