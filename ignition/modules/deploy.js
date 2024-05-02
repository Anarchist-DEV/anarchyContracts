// author : KOOLNERD
const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");



// module.exports = buildModule("ANARCHY_TOKEN", (m) => {

//   const ANARCHY_TOKEN = m.contract("ANARCHY_TOKEN");

//   return { ANARCHY_TOKEN };
// });

module.exports = buildModule("vesting", (m) =>{
  const _token = m.getParameter("_token", "0xe6bC379F8ECDB6861cE9eb45248Bd5410B2eAa1a");
  const _teamAddress = m.getParameter("_teamAddress", "0xD567f35AE3dC4AB36ce7A1714E93A1600ec4D4E0");
  const _advisorAddress = m.getParameter("_advisorAddress", "0x5F1e9CD2f0274B1B979fbf23fC8E9d5f5643FE29");
  const _privateInvestorAddress = m.getParameter("_privateInvestorAddress", "0x1A927E49B5C97268E282E3100F0Df936F69F2993");
  const _seedInvestorAddress = m.getParameter("_seedInvestorAddress", "0xb0BFD3B44De29d2cF5F5537A859aEfE9a12bc4CA");
  const __preSeedInvestorAddress = m.getParameter("__preSeedInvestorAddress","0xb1C5924d213598Aff40D5A8083a143B0174d2Da2");

  const vesting = m.contract("vesting", [_token], [_teamAddress], [_advisorAddress], [_privateInvestorAddress], [_seedInvestorAddress], [__preSeedInvestorAddress]);
  return {vesting};
} ) ;