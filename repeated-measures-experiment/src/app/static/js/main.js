// Get a reference to the database service
var database = firebase.database();


// lists of trials (will need to find a way to counterbalance this)
const sdList = Array(6).fill("high").concat(Array(6).fill("low"))
const oddsList = [0.025, 0.100, 0.250, 0.750, 0.900, 0.975, 0.025, 0.100, 0.250, 0.750, 0.900, 0.975]

// set src file for stimulus img
let filepath
if (routeVars.trial === "practice") {
    filepath = "../img/" + routeVars.cond + "-high sd, 0.25 odds" + extension();
} else {
    filepath = "../img/" + routeVars.cond + "-" + sdList[routeVars.trial] + " sd, " + oddsList[routeVars.trial] + " odds" + extension();
}
$("#stim").attr("src", filepath);

// slider callbacks
let cles = -1,
    bet = -1;
$(document).ready(function () {
    // update label
    $("#prob").on("input", function () {
        $("#prob-selected").html(this.value + " out of 100")
    })
    // update responses in database
    $("#prob").change("input", function () {
        cles = this.value;
        let respObj = {
            "workerId": routeVars.workerId,
            "condition": routeVars.cond,
            "trial": routeVars.trial,
            "cles": cles,
            "bet": bet
        }
        updateResponseData(respObj)
    })
    
    // update label
    $("#bet").on("input", function () {
        $("#bet-selected").html("$" + this.value + " out of $1")
    })
    // update responses in database
    $("#bet").change("input", function () {
        bet = this.value;
        let respObj = {
            "workerId": routeVars.workerId,
            "condition": routeVars.cond,
            "trial": routeVars.trial, 
            "cles": cles,
            "bet": bet
        }
        updateResponseData(respObj)
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
            trialRef.update(respObj);
        }
    })
}