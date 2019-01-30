// determine file extension for stimulus
let reHOPs = /HOPs/;
let extension
if (reHOPs.test(routeVars.cond)) {
    extension = ".gif";
} else {
    extension = ".svg";
}
// set src of stimulus img
const filepath = "../img/" + routeVars.cond + "-high sd, 0.25 odds" + extension;
$("#stim").attr("src", filepath);


// reactively push responses to firebase
 function updateResponseData(respObj) {
    let workerRef = database.ref("responses/" + routeVars.workerId)
    workerRef.once("value", function (snapshot) {
        if (!snapshot.exists()) {
            // create a response entry for this user
            workerRef.set(respObj)
        } else { // if repsonses already exist for this user
            // check if this is a new trial
            if (snapshot.val().trial !== respObj.trial) { 
                // push new trial
                workerRef.push(respObj)
            } else { 
                // update existing trial
                workerRef.update(respObj)
            }
        }
    })
}


// slider callbacks
$(document).ready(function () {
    // update label
    $("#prob").on("input", function () {
        $("#prob-selected").html(this.value + " out of 100")
    })
    // update responses in database
    $("#prob").change("input", function () {
        let respObj = {
            "workerId": routeVars.workerId,
            "condition": routeVars.cond,
            "trial": "practice", // set dynamically in main experiment
            "cles": this.value
        }
        updateResponseData(respObj)
    })
    
    // update label
    $("#bet").on("input", function () {
        $("#bet-selected").html("$" + this.value + " out of $1")
    })
    // update responses in database
    $("#bet").change("input", function () {
        let respObj = {
            "workerId": routeVars.workerId,
            "condition": routeVars.cond,
            "trial": "practice", // set dynamically in main experiment
            "bet": this.value
        }
        updateResponseData(respObj)
    })
})