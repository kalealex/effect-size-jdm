// Get a reference to the database service
// var database = firebase.database();

// once page is ready...
$(document).ready(function () {
    // query db for total bonus across trials
    let totalBonus = 0,
        token;
    fetch('/api/check_responses', {
        method: "post",
        body: JSON.stringify({ "workerId": routeVars.workerId })
    }).then(function (resp) {
        console.log("resp", resp);
        return resp.json();
    }).then(function (result) {
        console.log("result", result);
        if ($.isEmptyObject(result)) {
            // what to do if entry is missing?
            console.log("No responses db entry found for worker", routeVars.workerId);
            $("#token").html("Your workerId is not logged in our database. Please check that your workerId is properly provided as a url parameter, and reload the page.");
        } else {
            // add up pay across non-practice trials
            for (key in result) {
                if (key != "practice") {
                    totalBonus += result[key].pay;
                }
            }
        }
    }).catch(function (err) {
        console.log("error", err);
    })

    // let respRef = database.ref("responses/" + routeVars.workerId)
    // respRef.once("value", function (snapshot) {
    //     if (!snapshot.exists()) {
    //         // what to do if entry is missing?
    //         console.log("No responses db entry found for worker", routeVars.workerId);
    //     } else {
    //         // add up pay across non-practice trials
    //         trials = snapshot.val();
    //         for (key in trials) {
    //             if (key != "practice") {
    //                 totalBonus += trials[key].pay;
    //             }
    //         }
    //     }
    // })

    
    // query db for token based on workerId
    fetch('/api/check_workers', {
        method: "post",
        body: JSON.stringify({ 
            "workerId": routeVars.workerId, 
            "bonus": totalBonus }) // this adds the worker's bonus to the db
    }).then(function (resp) {
        console.log("resp", resp);
        return resp.json();
    }).then(function (result) {
        console.log("result", result);
        if ($.isEmptyObject(result)) {
            // what to do if entry is missing?
            console.log("No workers db entry found for worker", routeVars.workerId);
            $("#token").html("Your workerId is not logged in our database. Please check that your workerId is properly provided as a url parameter, and reload the page.");
        } else {
            // provide token
            token = result.token;
            $("#token").html(token);
        }
    }).catch(function (err) {
        console.log("error", err);
    })

    // let workerRef = database.ref("workers/" + routeVars.workerId);
    // workerRef.once("value", function (snapshot) {
    //     if (!snapshot.exists()) {
    //         // what to do if entry is missing?
    //         console.log("No workers db entry found for worker", routeVars.workerId);
    //     } else {
    //         // provide token
    //         token = snapshot.val().token;
    //         $("#token").html(token);
    //         // update db to log bonus
    //         workerRef.update({"bonus": totalBonus})
    //     }
    // })
})

