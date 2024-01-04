import {MersenneTwister} from './mersenne-twister.js';
import {seedFromDate} from './random-util.js';

function replaceLogo() {
    const logo = document.querySelector('img');
    logo.src = '/images/earbuds.png';
}

const rng = new MersenneTwister(seedFromDate(new Date()));

if ((rng.random_int() % 32) === 0) {
    replaceLogo();
}
