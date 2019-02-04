// Get a reference to the database service
var database = firebase.database();

// callbacks to record responses
$(document).ready(function () {
    // update responses in database
    if ($("#strategy").length == 0) {
        // case 4b_survey
        for (let i = 1; i <= 11; i++) {
            $("#numeracy-" + i).change("input", function () {
                let key = "" + i;
                let respObj = {};
                respObj[key] = this.value;
                updateSurvey(respObj);
            })
        }
    } else {
        // case 4a_strategy
        $("#strategy").change("input", function () {
            let respObj = {
                "workerId": routeVars.workerId,
                "condition": routeVars.cond,
                "strategy": this.value
            }
            updateStrategy(respObj);
        })
    }
    
})

// disable enter key submit, which messes up url parameters
$('#survey').on('keyup keypress', function(e) {
    var keyCode = e.keyCode || e.which;
    if (keyCode === 13) { 
    e.preventDefault();
    return false;
    }
});

// reactively push strategy response to firebase
function updateStrategy(responseObj) {
    let workerRef = database.ref("survey/" + routeVars.workerId)
    workerRef.once("value", function (snapshot) {
        if (!snapshot.exists()) {
            // create a survey entry for this worker
            workerRef.set(responseObj);
        } else {
            // update existing survey response object
            workerRef.update(responseObj);
        }
    })
}

// reactively push survey responses to firebase
function updateSurvey(responseObj) {
    let surveyRef = database.ref("survey/" + routeVars.workerId + "/numeracy")
    surveyRef.once("value", function (snapshot) {
        if (!snapshot.exists()) {
            // create a survey entry for this worker
            surveyRef.set(responseObj);
        } else {
            // update existing survey response object
            surveyRef.update(responseObj);
        }
    })
}