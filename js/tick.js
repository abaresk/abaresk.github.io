// One frame of gameplay (in ms)
const TICK = 1000 / 60;

async function sleepMs(delayMs) {
    return new Promise((resolve) => { setTimeout(resolve, delayMs); });
}

async function sleepTicks(delayTicks) {
    await sleepMs(delayTicks * TICK);
}

export {TICK, sleepMs, sleepTicks};