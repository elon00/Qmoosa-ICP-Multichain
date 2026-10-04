// Qmoosa ICP - Generate & Inspect ICP Public Principal
import crypto from 'node:crypto';
import zlib from 'node:zlib';

const B32_ALPHABET = 'abcdefghijklmnopqrstuvwxyz234567';

function base32Encode(buffer) {
  let bits = 0;
  let value = 0;
  let output = '';

  for (let i = 0; i < buffer.length; i++) {
    value = (value << 8) | buffer[i];
    bits += 8;

    while (bits >= 5) {
      output += B32_ALPHABET[(value >>> (bits - 5)) & 31];
      bits -= 5;
    }
  }

  if (bits > 0) {
    output += B32_ALPHABET[(value << (5 - bits)) & 31];
  }

  return output;
}

export function generateICPPrincipal() {
  const { publicKey } = crypto.generateKeyPairSync('ed25519');
  const der = publicKey.export({ type: 'spki', format: 'der' });

  // SHA-224 of DER public key
  const hash224 = crypto.createHash('sha224').update(der).digest();
  // Self-authenticating suffix byte (0x02)
  const principalBytes = Buffer.concat([hash224, Buffer.from([0x02])]);

  // CRC32 checksum (4 bytes big-endian)
  const crc = zlib.crc32(principalBytes);
  const crcBuf = Buffer.alloc(4);
  crcBuf.writeUInt32BE(crc, 0);

  const fullBuf = Buffer.concat([crcBuf, principalBytes]);
  const b32 = base32Encode(fullBuf);

  // Group into 5-char blocks separated by hyphens
  const principalText = b32.match(/.{1,5}/g).join('-');
  return principalText;
}

const principal = generateICPPrincipal();
console.log('================================================================');
console.log('         QMOOSA ICP -- PUBLIC PRINCIPAL GENERATOR               ');
console.log('================================================================');
console.log('Generated Public Principal:');
console.log(principal);
console.log('');
console.log('Use this Principal at:');
console.log('1. Free Faucet: https://faucet.internetcomputer.org/ (Select TESTICP)');
console.log('2. TESTICP Ledger Canister: xafvr-biaaa-aaaai-aql5q-cai');
console.log('3. Dashboard Explorer: https://dashboard.internetcomputer.org/canister/xafvr-biaaa-aaaai-aql5q-cai');
console.log('================================================================');
