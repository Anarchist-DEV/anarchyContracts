// author : KOOLNERD
const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");



module.exports = buildModule("ANARCHY_TOKEN", (m) => {

  const ANARCHY_TOKEN = m.contract("ANARCHY_TOKEN");

  return { ANARCHY_TOKEN };
});
