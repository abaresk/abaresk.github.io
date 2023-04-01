const heading = document.getElementById('home-heading');

// `date1` is the user's local time.
// `date2` is assumed to be midnight at UTC.
function sameDate(date1, date2) {
    return (date1.getMonth() === date2.getUTCMonth() &&
            date1.getDate() === date2.getUTCDate());
}

function daysSinceEpoch(date) {
    const epoch = new Date();
    epoch.setFullYear(1970);
    epoch.setMonth(0);
    epoch.setDate(1);
    epoch.setHours(0);
    epoch.setMinutes(0);
    epoch.setSeconds(0);
    epoch.setMilliseconds(0);

    const difference = date.getTime() - epoch.getTime();
    return Math.floor(difference / (1000 * 3600 * 24));
}

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

function updateHeading(date) {
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

heading.innerText = updateHeading(new Date());
