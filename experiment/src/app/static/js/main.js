// Get a reference to the database service
var database = firebase.database();

// lists of trials
const sdList = Array(10).fill(1).concat(Array(10).fill(5))
const oddsList = [0.025, 0.055, 0.116, 0.228, 0.400, 0.600, 0.772, 0.884, 0.945, 0.975, 0.025, 0.055, 0.116, 0.228, 0.400, 0.600, 0.772, 0.884, 0.945, 0.975];

// determine stimulus parameters on current trial
let sd, odds, filepath;
if (routeVars.trial === "practice") {   // TODO add special practice stimuli with graphical legends
    sd = 5;
    odds = 0.228;
    filepath = "../img/" + routeVars.cond + "-" + sd + "_sd_" + odds + "_odds" + extension();
    // filepath = "../img/" + routeVars.cond + "-practice" + extension();
} else { // trial index used for counterbalancing
    console.log("trial index", routeVars.trialIdx);
    sd = sdList[routeVars.trialIdx];
    odds = oddsList[routeVars.trialIdx];
    filepath = "../img/" + routeVars.cond + "-" + sd + "_sd_" + odds + "_odds" + extension();
}
// set src file for stimulus img
console.log("loading stim", filepath)
$("#stim").attr("src", filepath);

// slider callbacks
let respObj = {
    "workerId": routeVars.workerId,
    "condition": routeVars.cond,
    "trial": routeVars.trial,
    "trialIdx": routeVars.trialIdx,
    "groundTruth": odds,
    "sdDiff": sd,
    "cles": -1,
    "bet": -1,
    "pay": -1
}
$(document).ready(function () { // TODO fetch starting value from db on refresh
    // update label
    $("#prob").on("input", function () {
        if (this.value == '') {
            $("#prob-selected").html("No response")
        } else if (isNaN(this.value)) {
            $("#prob-selected").html("Please provide a numeric answer")
        } else if (+this.value > 100 || +this.value < 0) {
            $("#prob-selected").html("Please provide a value between 0 and 100")
        } else {
            $("#prob-selected").html(this.value + " out of 100")
        }
    })
    // update responses in database
    $("#prob").change("input", function () {
        if (this.value == '' || isNaN(this.value)) {
            respObj.cles = this.value;
        } else {
            respObj.cles = +this.value;
        }
        updateResponseData(respObj);
    })
    
    // update label
    $("#bet").on("input", function () {
        if (this.value == '') {
            $("#bet-selected").html("No response")
        } else if (isNaN(this.value)) {
            $("#bet-selected").html("Please provide a numeric answer")
        } else if (+this.value > Math.round(routeVars.budget * 100) || +this.value < 1) {
            $("#bet-selected").html("Please provide a value between 1 and " + Math.round(routeVars.budget * 100) + " cents")
        } else {
            $("#bet-selected").html(Math.round(+this.value) + " out of " + Math.round(routeVars.budget * 100) + " cents")
        }
    })
    // update responses in database
    $("#bet").change("input", function () {
        if (this.value == '' || isNaN(this.value)) {
            respObj.bet = this.value;
        } else {
            // convert bet to dollars for storage
            respObj.bet = roundCent(+this.value / 100);
        }
        updateResponseData(respObj);
    })
})

// helper functions:
// determine file extension for stimulus
function extension() {
    let reHOPs = /HOPs/;
    if (reHOPs.test(routeVars.cond)) {
        return ".gif";
    } else {
        return ".svg";
    }
}

// reactively push responses to firebase
function updateResponseData(respObj) {
    let trialRef = database.ref("responses/" + routeVars.workerId + "/" + routeVars.trial)
    trialRef.once("value", function (snapshot) {
        if (!snapshot.exists()) {
            // create a response entry for this trial
            trialRef.set(respObj);
        } else { // if repsonses already exist for this trial
            // update existing trial
            if (routeVars.testMode || snapshot.val().pay === -1) { // only allow updates for trials where pay is tbd
                trialRef.update(respObj);
            }
        }
    })
}

// provide feedback on user responses
function feedback() {
    // catch non-numeric and out of range responses
    if (respObj.cles === -1 || respObj.cles == '' || isNaN(respObj.cles) || 
        respObj.bet === -1 || respObj.bet == '' || isNaN(respObj.bet)) {
        console.log("response object", respObj);
        // prompt for numeric response
        $("#feedback-catch").html("You need to provide a numeric response to both questions.");
        $("#feedback-catch").addClass("show");
        // wait to reset display
        setTimeout(function () {
            $("#feedback-catch").removeClass("show");
        }, 4250);
    } else if (respObj.cles < 0 || respObj.cles > 100 || 
        respObj.bet < 0.01 || respObj.bet > routeVars.budget) {
        console.log("response object", respObj);
        // prompt for value in range
        $("#feedback-catch").html("You need to provide in range responses to both questions.");
        $("#feedback-catch").addClass("show");
        // wait to reset display
        setTimeout(function () {
            $("#feedback-catch").removeClass("show");
        }, 4250);
    } else {
        console.log("response object", respObj);
        // disable input so that users cannot edit responses
        $("input").attr("disabled", "disabled");
        // hide Feedback button
        $("#feedback-btn").css("display", "none");
        // simulate outcome based on odds of victory for this stimulus
        let bet = respObj.bet,
            keep = roundCent((routeVars.budget - bet) * (1 - 0.25)), // flat tax
            win = 0; // update if they win
        if (outcome(odds)) {
            // the user's team wins
            $("#feedback-txt").html("Winner: Team A")
                .css("color", "#e41a1c");
            // calculate winnings
            win = tieredTax(bet / odds);
        } else {
            // the user's team loses
            $("#feedback-txt").html("Winner: Team B")
                .css("color", "#377eb8");
        }
        // populate table showing bet, keep, win, and total bonus amounts
        $("#bet-amnt").html("$" + roundCent(bet));
        $("#keep-amnt").html("$" + roundCent(keep));
        $("#win-amnt").html("$" + roundCent(win));
        $("#bonus-amnt").html("$" + roundCent(keep + win));
        // push pay to db (thus disabling further updates)
        respObj.pay = keep + win;
        updateResponseData(respObj);
        // show feedback and button to advance to next trial
        $("#feedback-block").css("display","block")
            .css("background-color", "#f7fbff");
    }
}

// biased coin flip for simulating wins and losses
function outcome(odds) {
    return Math.random() <= odds;
    // return true;
}

// tiered tax on winnings
function tieredTax(winnings) {
    let tiers = [0, 0.5, 1, 1.5, 2],
    rates = [0.1, 0.2, 0.3, 0.4, 0.5],
    i = 0,
    taxedWinnings = 0;
    // cycle through tiers
    while (i < tiers.length && (winnings - tiers[i]) > 0) {
        // how much money in this tier does the user keep?
        taxedWinnings += Math.min(0.5, (winnings - tiers[i])) * (1 - rates[i]);
        // counter
        i++;
    }
    return roundCent(taxedWinnings);
}

// round to nearest cent
function roundCent(amount) {
    return Math.round(amount * 100) / 100;
}