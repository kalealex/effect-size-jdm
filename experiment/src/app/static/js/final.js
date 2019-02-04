// Get a reference to the database service
var database = firebase.database();

// once page is ready...
let token;
$(document).ready(function () {
    // query db for total bonus across trials
    let totalBonus = 0;
    let respRef = database.ref("responses/" + routeVars.workerId)
    respRef.once("value", function (snapshot) {
        if (!snapshot.exists()) {
            // what to do if entry is missing?
            console.log("No responses db entry found for worker", routeVars.workerId);
        } else {
            // add up pay across non-practice trials
            trials = snapshot.val();
            for (key in trials) {
                if (key != "practice") {
                    totalBonus += trials[key].pay;
                }
            }
        }
    })
    // query db for token based on workerId
    let workerRef = database.ref("workers/" + routeVars.workerId);
    workerRef.once("value", function (snapshot) {
        if (!snapshot.exists()) {
            // what to do if entry is missing?
            console.log("No workers db entry found for worker", routeVars.workerId);
        } else {
            // provide token
            token = snapshot.val().token;
            $("#token").html(token);
            // update db to log bonus
            workerRef.update({"bonus": totalBonus})
        }
    })
})

