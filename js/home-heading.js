import { PcgRandom } from './pcg-random.js';
import { sameDate, daysSinceEpoch } from './date-util.js';
import { seedFromDate } from './random-util.js';
import { sleepTicks } from './tick.js';

const clickMedicAnnivEmoticons = [
    `HUMANBODY NETWORK NAVIGATOR | CLICK SYSTEM 4`,
];

const pokemonDayEmoticons = [
    'ϞϞ(๑⚈ ․̫ ⚈๑)∩',
    '(╯°□°)╯︵◓',
];

const aprilFoolsEmoticons = [
    '(☞ﾟ∀ﾟ)☞',
    '⫷(≧ ᵔ̃ ●ᵔ̃≦)⫸',
    '🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡',
];

const halloweenEmoticons = [
    '༼ つ ❍_❍ ༽つ',
    '(㇏(>ᵥᵥ<)ノ)',
];

const christmasEmoticons = [
    '༝﹡˖˟ ⸜₍⁽ˊ꒳ˋ⁾₎⸝ ༝﹡˖˟',
    '-ˋˏ ༻🎄༺ ˎˏ ༻🎄༺ ˎˊ- ̤',
    '⋆(ㆆᴗㆆ)*✲ﾟ*｡⋆',
    '(╬ᇂ..ᇂ)o彡°',
];

const normalHeadings = [
    `♫ヽ(๑╹◡╹๑)ﾉ♬`,
    `Abaresk's Blog`,
    `Abaresk's Blog`,
    `Abaresk's Blog`,
    `૮ ˆﻌˆ ა`,
    `Abaresk's Blog`,
    `Abaresk's Blog`,
    `♫ヽ(๑╹◡╹๑)ﾉ♬`,
    `Abaresk's Blog`,
    `Abaresk's Blog`,
    `Abaresk's Blog`,
    `[+..••]`,
    `Abaresk's Blog`,
    `Abaresk's Blog`,
    `૮ ˆﻌˆ ა`,
    `Abaresk's Blog`,
    `Abaresk's Blog`,
    `(ㆆ_ㆆ)`,
    `♫ヽ(๑╹◡╹๑)ﾉ♬`,
    `Abaresk's Blog`,
    `Abaresk's Blog`,
    `Abaresk's Blog`,
    `[+..••]`,
    `Abaresk's Blog`,
];

function chooseEmoticonForYear(date, emoticons) {
    return emoticons[date.getYear() % emoticons.length];
}

function chooseEmoticonForDay(date, emoticons) {
    return emoticons[daysSinceEpoch(date) % emoticons.length];
}

function headingText(date) {
    if (sameDate(date, new Date('2020-01-28'))) {
        return chooseEmoticonForYear(date, clickMedicAnnivEmoticons);
    }
    if (sameDate(date, new Date('2020-02-27'))) {
        return chooseEmoticonForYear(date, pokemonDayEmoticons);
    }
    if (sameDate(date, new Date('2020-04-01'))) {
        return chooseEmoticonForYear(date, aprilFoolsEmoticons);
    }
    if (sameDate(date, new Date('2020-10-31'))) {
        return chooseEmoticonForYear(date, halloweenEmoticons);
    }
    if (sameDate(date, new Date('2020-12-25'))) {
        return chooseEmoticonForYear(date, christmasEmoticons);
    }
    return chooseEmoticonForDay(date, normalHeadings);
}

/**
 * Cipher animation.
 *
 * Random cipher text effect, like in Click Medic.
 * https://youtu.be/pHJ-XM9FD0I&t=770
*/
const alphabet = 'abcdefghijklmnopqrstuvwxyz'.split('');
const upperAlphabet = 'abcdefghijklmnopqrstuvwxyz'.toUpperCase().split('');
const greekAlphabet = 'αβγδεζηθικλμνξοπρστυφχψω'.split('');
const upperGreekAlphabet = 'ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ'.split('');
const numbers = '0123456789'.split('');
const specialChars = '<>()[]!?#;,.áéíóúâêîôûàèìòùãõ¡£¢∞§¶•˚√∫'.split('');

const cipherChars = alphabet.concat(
    upperAlphabet, greekAlphabet, upperGreekAlphabet, numbers, specialChars);

const MEDIUM_FRAME_DELAY = 2;
const SLOW_FRAME_DELAY = 3;
const DAMPENING_FACTOR = 2;

async function cipherHeadingAnimation(rng, headingEl, text) {
    const randomIdxs = [...Array(text.length).keys()];

    // Energy loading animation (max speed, completely random).
    for (let i = 0; i < 100; i++) {
        await sleepTicks(1);
        await updateCipherHeading(rng, headingEl, text, randomIdxs);
    }

    // Slowing down (lower speed, completely random).
    for (let i = 0; i < 25; i++) {
        await sleepTicks(1);

        // Only update every `MEDIUM_FRAME_DELAY` frames.
        if (i % MEDIUM_FRAME_DELAY !== 0) continue;

        await updateCipherHeading(rng, headingEl, text, randomIdxs);
    }

    // Settling animation (lower speed, gradually stabilizing).
    for (let i = 0; i < text.length * SLOW_FRAME_DELAY * DAMPENING_FACTOR; i++) {
        await sleepTicks(1);

        // Only update every `SLOW_FRAME_DELAY` frames.
        if (i % SLOW_FRAME_DELAY !== 0) continue;

        // Keep the same number of random characters for `DAMPENING_FACTOR`
        // shots. Then use one less random character.
        if (i % (SLOW_FRAME_DELAY * DAMPENING_FACTOR) === 0) {
            randomIdxs.splice(rng.next32() % randomIdxs.length, 1);
        }
        await updateCipherHeading(rng, headingEl, text, randomIdxs);
    }
}

// `randomIdxs` is an array of indices within `text` that should appear random.
async function updateCipherHeading(rng, headingEl, text, randomIdxs) {
    headingEl.innerText = cipherText(rng, text, randomIdxs);
}

function cipherText(rng, text, randomIdxs) {
    const idxSet = new Set(randomIdxs);
    const chars = [];
    for (let i = 0; i < text.length; i++) {
        if (idxSet.has(i)) {
            chars.push(cipherChars[rng.next32() % cipherChars.length]);
        } else {
            chars.push(text[i]);
        }
    }
    return chars.join('');
}


function updateHeadingText(date) {
    const rng = new PcgRandom(seedFromDate(date));
    const headingEl = document.getElementById('home-heading');
    const text = headingText(date);

    // Click Medic came out January 28, 1999 in Japan. 68 people are credited on
    // Click Medic.
    if (sameDate(date, new Date('2020-01-28') || rng.next32() % 68 === 0)) {
        cipherHeadingAnimation(rng, headingEl, text);
    } else {
        // Otherwise, just update the heading.
        headingEl.innerText = text;
    }
}

updateHeadingText(new Date());
