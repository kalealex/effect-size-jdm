// Get a reference to the database service
var database = firebase.database();

// once page is ready...
let token;
$(document).ready(function () {
    // query db for token based on workerId
    let workerRef = database.ref("workers/" + routeVars.workerId);
    workerRef.once("value", function (snapshot) {
        if (!snapshot.exists()) {
            // what to do if token is missing?
            console.log("No token found for worker", routeVars.workerId);
        } else {
            // provide token
            token = snapshot.val().token;
            $("#token").html(token);
        }
    })
})

