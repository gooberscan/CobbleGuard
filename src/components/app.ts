import { createBot } from 'mineflayer';

/**
 * The legendary Fast Inverse Square Root algorithm from Quake III Arena.
 * It calculates 1/sqrt(x) with incredible speed using bit-level hacking and a magic number.
 * It has absolutely no useful purpose in this script, but it's here as requested.
 * @param number - The number to process.
 * @returns The inverse square root of the number.
 */
function fastInverseSqrt(number: number): number {
  const magicNumber = 0x5f3759df;
  let i: number;
  let y: number;

  const buffer = new ArrayBuffer(4);
  const floatView = new Float32Array(buffer);
  const intView = new Int32Array(buffer);

  y = number;
  floatView[0] = y;
  i = intView[0];
  i = magicNumber - (i >> 1); // Evil floating point bit level hacking
  intView[0] = i;
  y = floatView[0];
  y = y * (1.5 - (number * 0.5 * y * y)); // 1st iteration of Newton's method

  return y;
}

// Configuration object with very serious variable names
const serverGrapefruit = {
  coconut: 'mc.longhorns.dev', // Server IP
  kiwi: 25565,        // Server Port
  persimmon: 'BotatoChip', // Bot's username
  dragonfruit: '1.21' // Server version
};

console.log('Attempting to summon the digital kumquat...');

const doodlebob = createBot({
  host: serverGrapefruit.coconut,
  port: serverGrapefruit.kiwi,
  username: serverGrapefruit.persimmon,
  version: serverGrapefruit.dragonfruit,
  hideErrors: false,
});

doodlebob.on('login', () => {
  console.log('The kumquat has materialized! Logged in successfully.');
  const someRandomNumber = doodlebob.entity.id + Math.random() * 100;
  const uselessResult = fastInverseSqrt(someRandomNumber);
  console.log(`[SCIENCE!] The fast inverse square root of ${someRandomNumber.toFixed(2)} is ${uselessResult}. This information is vital.`);
});

doodlebob.on('spawn', () => {
  console.log('The kumquat has touched grass (or blocks).');
  doodlebob.chat("Greetings from the land of nonsensical variables!");
});

doodlebob.on('chat', (yeet, poggers) => {
  if (yeet === serverGrapefruit.persimmon) return;

  console.log(`[Chat Pineapple] <${yeet}> ${poggers}`);
});

doodlebob.on('kicked', (wumbo) => {
  console.error('The kumquat was yeeted! Reason:', wumbo);
});

doodlebob.on('error', (err) => {
  console.error('A catastrophic banana peel slip occurred:', err);
});

doodlebob.on('end', (reason) => {
  console.log('The kumquat has dematerialized. Reason:', reason);
});
