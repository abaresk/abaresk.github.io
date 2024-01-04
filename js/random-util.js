function seedFromDate(date) {
    return date.getFullYear() + (date.getMonth() + 1) * 0x100 + date.getDate() * 0x10000;
}

export {seedFromDate};
