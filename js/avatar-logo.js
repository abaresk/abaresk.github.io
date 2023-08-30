import {MersenneTwister} from './mersenne-twister.js';

function seedFromDate(date) {
    return date.getFullYear() + (date.getMonth() + 1) * 0x100 + date.getDate() * 0x10000;
}

function replaceLogo() {
    const logo = document.querySelector('img');
    logo.src = '/images/earbuds.png';
}

const rng = new MersenneTwister(seedFromDate(new Date()));

if ((rng.random_int() % 32) === 0) {
    replaceLogo();
}
