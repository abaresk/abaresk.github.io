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

export {daysSinceEpoch, sameDate};
