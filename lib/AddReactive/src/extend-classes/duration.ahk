class Duration {
    static use() {
        if (!ARConfig.useExtendClasses) {
            return
        }

        for method, enabled in ARConfig.enableExtendClasses.duration.integer.OwnProps() {
            if (enabled) {
                Integer.Prototype.%method% := ObjBindMethod(this, method)
            }
        }

        for method, enabled in ARConfig.enableExtendClasses.duration.string.OwnProps() {
            if (enabled) {
                String.Prototype.%method% := ObjBindMethod(this, method)
            }
        }
    }

    static seconds(duration) => TimeUnit(duration, "Seconds")
    static minutes(duration) => TimeUnit(duration, "Minutes")
    static hours(duration) => TimeUnit(duration, "Hours")
    static days(duration) => TimeUnit(duration, "Days")

    static secondsTo(fromDate, toDate) => DateDiff(toDate, fromDate, "Seconds")
    static minutesTo(fromDate, toDate) => DateDiff(toDate, fromDate, "Minutes")
    static hoursTo(fromDate, toDate) => DateDiff(toDate, fromDate, "Hours")
    static daysTo(fromDate, toDate) => DateDiff(toDate, fromDate, "Days")

    static tomorrow(fromDate, time := "000000") => this.nextDay(fromDate, time)
    static nextDay(fromDate, time := "000000") => FormatTime(DateAdd(fromDate, 1, "Days"), "yyyyMMdd") . time
    static yesterday(fromDate, time := "000000") => FormatTime(DateAdd(fromDate, -1, "Days"), "yyyyMMdd") . time
}

class TimeUnit {
    __New(value, unitType) {
        this.value := value
        this.unitType := unitType
        this.unitInSeconds := {
            Seconds: 1,
            Minutes: 60,
            Hours: 3600,
            Days: 86400
        }
    }

    ago() => DateAdd(A_Now, 0 - this.value, this.unitType)

    fromNow() => DateAdd(A_Now, this.value, this.unitType)

    after(time) => this.since(time)
    since(time) => DateAdd(time, this.value, this.unitType)

    before(time) => this.until(time)
    until(time) => DateAdd(time, 0 - this.value, this.unitType)

    inSeconds() => this.unitInSeconds.%this.unitType%
    inMinutes() => this.unitInSeconds.%this.unitType% / 60
    inHours() => this.unitInSeconds.%this.unitType% / 60 / 60
    inDays() => this.unitInSeconds.%this.unitType% / 60 / 60 / 24
}