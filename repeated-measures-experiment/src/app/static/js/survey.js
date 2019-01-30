// Get a reference to the database service
var database = firebase.database();

// callbacks to record responses
// TODO: adapt the following pattern to work for each item in the survey
let respObj = {
    "workerId": routeVars.workerId,
    "condition": routeVars.cond,
    "field": ""
}
// $(document).ready(function () {
    // update responses in database
    $("#field").change("input", function () {
        respObj.field = this.value;
        updateSurveyData(respObj)
    })
// })

// reactively push survey responses to firebase
function updateSurveyData(respObj) {
    console.log("survey/" + routeVars.workerId)
    let workerRef = database.ref("survey/" + routeVars.workerId)
    workerRef.once("value", function (snapshot) {
        console.log(snapshot.val())
        if (!snapshot.exists()) {
            // create a survey entry for this worker
            workerRef.set(respObj);
        } else {
            // update existing survey response object
            workerRef.update(respObj);
        }
    })
}