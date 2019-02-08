// Get a reference to the database service
// var database = firebase.database();

// callbacks to record and manage responses
$(document).ready(function () {
    // update responses in database
    if ($("#strategy").length == 0) {
        // case 4b_survey
        for (let i = 1; i <= 11; i++) {
            // treat radio button and text entry responses differently
            if (i === 4 || i === 5) {
                // radio buttons
                $("input[type=radio][name=numeracy-" + i + "]").click(function () {
                    let key = "" + i;
                    let respObj = { "workerId": routeVars.workerId };
                    if (this.value == '' || isNaN(this.value)) {
                        respObj[key] = this.value;
                    } else {
                        respObj[key] = +this.value;
                    }
                    // console.log(respObj);
                    updateSurvey(respObj);
                });
            } else {
                // text entry
                $("#numeracy-" + i).change("input", function () {
                    let key = "" + i;
                    let respObj = { "workerId": routeVars.workerId };
                    if (this.value == '' || isNaN(this.value)) {
                        respObj[key] = this.value;
                    } else {
                        respObj[key] = +this.value;
                    }
                    // console.log(respObj);
                    updateSurvey(respObj);
                });
            }
        }
        // update labels
        $("#numeracy-1").on("input", function () {
            if (this.value == '') {
                $("#numeracy-1-selected").html("No response")
            } else if (isNaN(this.value)) {
                $("#numeracy-1-selected").html("Please provide a numeric answer")
            } else if (+this.value > 1000 || +this.value < 0) {
                $("#numeracy-1-selected").html("Please provide a value between 0 and 1000")
            } else {
                $("#numeracy-1-selected").html(Math.round(+this.value) + " out of 1000 rolls")
            }
        })
        $("#numeracy-2").on("input", function () {
            if (this.value == '') {
                $("#numeracy-2-selected").html("No response")
            } else if (isNaN(this.value)) {
                $("#numeracy-2-selected").html("Please provide a numeric answer")
            } else if (+this.value > 1000 || +this.value < 0) {
                $("#numeracy-2-selected").html("Please provide a value between 0 and 1000")
            } else {
                $("#numeracy-2-selected").html(Math.round(+this.value) + " out of 1000 people")
            }
        })
        $("#numeracy-3").on("input", function () {
            if (this.value == '') {
                $("#numeracy-3-selected").html("No response")
            } else if (isNaN(this.value)) {
                $("#numeracy-3-selected").html("Please provide a numeric answer")
            } else if (+this.value > 100 || +this.value < 0) {
                $("#numeracy-3-selected").html("Please provide a value between 0 and 100")
            } else {
                $("#numeracy-3-selected").html(+this.value + "% of tickets")
            }
        })
        $("#numeracy-6").on("input", function () {
            if (this.value == '') {
                $("#numeracy-6-selected").html("No response")
            } else if (isNaN(this.value)) {
                $("#numeracy-6-selected").html("Please provide a numeric answer")
            } else if (+this.value > 100 || +this.value < 0) {
                $("#numeracy-6-selected").html("Please provide a value between 0 and 100")
            } else {
                $("#numeracy-6-selected").html(+this.value + "%")
            }
        })
        $("#numeracy-7").on("input", function () {
            if (this.value == '') {
                $("#numeracy-7-selected").html("No response")
            } else if (isNaN(this.value)) {
                $("#numeracy-7-selected").html("Please provide a numeric answer")
            } else if (+this.value > 100 || +this.value < 0) {
                $("#numeracy-7-selected").html("Please provide a value between 0 and 100")
            } else {
                $("#numeracy-7-selected").html(Math.round(+this.value) + " in 100")
            }
        })
        $("#numeracy-8").on("input", function () {
            if (this.value == '') {
                $("#numeracy-8-selected").html("No response")
            } else if (isNaN(this.value)) {
                $("#numeracy-8-selected").html("Please provide a numeric answer")
            } else if (+this.value > 100 || +this.value < 0) {
                $("#numeracy-8-selected").html("Please provide a value between 0 and 100")
            } else {
                $("#numeracy-8-selected").html(Math.round(+this.value) + " out of 100 people")
            }
        })
        $("#numeracy-9").on("input", function () {
            if (this.value == '') {
                $("#numeracy-9-selected").html("No response")
            } else if (isNaN(this.value)) {
                $("#numeracy-9-selected").html("Please provide a numeric answer")
            } else if (+this.value > 1000 || +this.value < 0) {
                $("#numeracy-9-selected").html("Please provide a value between 0 and 1000")
            } else {
                $("#numeracy-9-selected").html(Math.round(+this.value) + " out of 1000 people")
            }
        })
        $("#numeracy-10").on("input", function () {
            if (this.value == '') {
                $("#numeracy-10-selected").html("No response")
            } else if (isNaN(this.value)) {
                $("#numeracy-10-selected").html("Please provide a numeric answer")
            } else if (+this.value > 100 || +this.value < 0) {
                $("#numeracy-10-selected").html("Please provide a value between 0 and 100")
            } else {
                $("#numeracy-10-selected").html(+this.value + "% chance")
            }
        })
        $("#numeracy-11").on("input", function () {
            if (this.value == '') {
                $("#numeracy-11-selected").html("No response")
            } else if (isNaN(this.value)) {
                $("#numeracy-11-selected").html("Please provide a numeric answer")
            } else if (+this.value > 10000 || +this.value < 0) {
                $("#numeracy-11-selected").html("Please provide a value between 0 and 10,000")
            } else {
                $("#numeracy-11-selected").html(Math.round(+this.value) + " out of 10,000 people")
            }
        })
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
        // add vis example
        let filepath = "../img/" + routeVars.cond + "-5_sd_0.228_odds" + extension();
        // console.log("loading stim", filepath);
        $("#stim").attr("src", filepath);
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

// disable click from bringing user to top of the page
$('a.feedback').click(function (e) {
    // Cancel the default action
    e.preventDefault();
});

// reactively push strategy response to firebase
function updateStrategy(responseObj) {
    fetch('/api/update_strategy', {
        method: "post",
        body: JSON.stringify(responseObj)
    }).then(function (resp) {
        console.log("resp", resp);
        return resp.json();
    }).then(function (result) {
        console.log("result", result);
    }).catch(function (err) {
        console.log("error", err);
    })

    // let workerRef = database.ref("survey/" + routeVars.workerId)
    // workerRef.once("value", function (snapshot) {
    //     if (!snapshot.exists()) {
    //         // create a survey entry for this worker
    //         workerRef.set(responseObj);
    //     } else {
    //         // update existing survey response object
    //         workerRef.update(responseObj);
    //     }
    // })
}

// reactively push survey responses to firebase
function updateSurvey(responseObj) {
    fetch('/api/update_survey', {
        method: "post",
        body: JSON.stringify(responseObj)
    }).then(function (resp) {
        console.log("resp", resp);
        return resp.json();
    }).then(function (result) {
        console.log("result", result);
    }).catch(function (err) {
        console.log("error", err);
    })

    // let surveyRef = database.ref("survey/" + routeVars.workerId + "/numeracy")
    // surveyRef.once("value", function (snapshot) {
    //     if (!snapshot.exists()) {
    //         // create a survey entry for this worker
    //         surveyRef.set(responseObj);
    //     } else {
    //         // update existing survey response object
    //         surveyRef.update(responseObj);
    //     }
    // })
}

// determine file extension for stimulus
function extension() {
    let reHOPs = /HOPs/;
    if (reHOPs.test(routeVars.cond)) {
        return ".gif";
    } else {
        return ".svg";
    }
}

// prevent invalid responses on submit
function handleSubmitStrategy() {
    fetch('/api/check_strategy', {
        method: "post",
        body: JSON.stringify({ "workerId": routeVars.workerId })
    }).then(function (resp) {
        console.log("resp", resp);
        return resp.json();
    }).then(function (result) {
        console.log("result", result);
        if (!result) {
            // no entry for worker: give feedback
            $("#feedback-catch").html("You have not submitted a response.");
            $("#feedback-catch").addClass("show");
            // wait to reset display
            setTimeout(function () {
                $("#feedback-catch").removeClass("show");
            }, 4250);
        } else if (!result.strategy) {
            // no response logged: give feedback
            $("#feedback-catch").html("You have not submitted a response.");
            $("#feedback-catch").addClass("show");
            // wait to reset display
            setTimeout(function () {
                $("#feedback-catch").removeClass("show");
            }, 4250);
        } else {
            // response is logged and valid: pass onto next page
            window.location.href = nextUrl;
        }
    }).catch(function (err) {
        console.log("error", err);
    })

    // // access response in db
    // let workerRef = database.ref("survey/" + routeVars.workerId);
    // workerRef.once("value", function (snapshot) {
    //     if (!snapshot.exists()) {
    //         // no entry for worker: give feedback
    //         $("#feedback-catch").html("You have not submitted a response.");
    //         $("#feedback-catch").addClass("show");
    //         // wait to reset display
    //         setTimeout(function () {
    //             $("#feedback-catch").removeClass("show");
    //         }, 4250);
    //     } else if (!snapshot.val().strategy) {
    //         // no response logged: give feedback
    //         $("#feedback-catch").html("You have not submitted a response.");
    //         $("#feedback-catch").addClass("show");
    //         // wait to reset display
    //         setTimeout(function () {
    //             $("#feedback-catch").removeClass("show");
    //         }, 4250);
    //     } else {
    //         // response is logged and valid: pass onto next page
    //         window.location.href = nextUrl;
    //     }
    // });
}

// prevent invalid responses on submit
function handleSubmitSurvey() {
    // use boolean to determine whether user passes to next page
    let moveOn = true;
    fetch('/api/check_survey', {
        method: "post",
        body: JSON.stringify({ "workerId": routeVars.workerId })
    }).then(function (resp) {
        console.log("resp", resp);
        return resp.json();
    }).then(function (result) {
        console.log("result", result);
        if (!result) {
            // no entry for worker: give feedback
            $("#feedback-catch").html("You have not submitted a response.");
            $("#feedback-catch").addClass("show");
            // wait to reset display
            setTimeout(function () {
                $("#feedback-catch").removeClass("show");
            }, 4250);
            moveOn = false;
        } else if (!result.numeracy) {
            // no responses have been logged: give feedback
            $("#feedback-catch").html("You have not submitted any responses.");
            $("#feedback-catch").addClass("show");
            // wait to reset display
            setTimeout(function () {
                $("#feedback-catch").removeClass("show");
            }, 4250);
            moveOn = false;
        } else {
            // iterate through survey items
            let survey = result.numeracy;
            const MAX_RESP = [1000, 1000, 100, 1000, 100, 100, 100, 100, 1000, 100, 10000]; // set up array of maximum allowable response on each item
            for (let i = 1; i <= 11; i++) {
                console.log("item " + i, survey[i])
                if (!survey[i]) {
                    // no response logged for this item: give feedback
                    $("#feedback-catch").html("You have not submitted a response for question " + i + ".");
                    $("#feedback-catch").addClass("show");
                    // wait to reset display
                    setTimeout(function () {
                        $("#feedback-catch").removeClass("show");
                    }, 4250);
                    moveOn = false;
                } else if (survey[i] == '' || isNaN(survey[i] || survey[i] < 0 || survey[i] > MAX_RESP[i - 1])) {
                    // invalid: give feedback
                    $("#feedback-catch").html("You have submitted an invalid response for question " + i + ".");
                    $("#feedback-catch").addClass("show");
                    // wait to reset display
                    setTimeout(function () {
                        $("#feedback-catch").removeClass("show");
                    }, 4250);
                    moveOn = false;
                }
            }
        }
        if (moveOn) {
            // all responses are logged and valid: pass onto next page
            window.location.href = nextUrl;
        }
    }).catch(function (err) {
        console.log("error", err);
    })

    // // access response in db
    // let workerRef = database.ref("survey/" + routeVars.workerId);
    // workerRef.once("value", function (snapshot) {
    //     if (!snapshot.exists()) {
    //         // no entry for worker: give feedback
    //         $("#feedback-catch").html("You have not submitted a response.");
    //         $("#feedback-catch").addClass("show");
    //         // wait to reset display
    //         setTimeout(function () {
    //             $("#feedback-catch").removeClass("show");
    //         }, 4250);
    //         moveOn = false;
    //     } else if (!snapshot.val().numeracy) {
    //         // no responses have been logged: give feedback
    //         $("#feedback-catch").html("You have not submitted any responses.");
    //         $("#feedback-catch").addClass("show");
    //         // wait to reset display
    //         setTimeout(function () {
    //             $("#feedback-catch").removeClass("show");
    //         }, 4250);
    //         moveOn = false;
    //     } else {
    //         // iterate through survey items
    //         let survey = snapshot.val().numeracy;
    //         const MAX_RESP = [1000, 1000, 100, 1000, 100, 100, 100, 100, 1000, 100, 10000]; // set up array of maximum allowable response on each item
    //         for (let i = 1; i <= 11; i++) {
    //             console.log("item " + i, survey[i])
    //             if (!survey[i]) {
    //                 // no response logged for this item: give feedback
    //                 $("#feedback-catch").html("You have not submitted a response for question " + i + ".");
    //                 $("#feedback-catch").addClass("show");
    //                 // wait to reset display
    //                 setTimeout(function () {
    //                     $("#feedback-catch").removeClass("show");
    //                 }, 4250);
    //                 moveOn = false;
    //             } else if (survey[i] == '' || isNaN(survey[i] || survey[i] < 0 || survey[i] > MAX_RESP[i - 1])) {
    //                 // invalid: give feedback
    //                 $("#feedback-catch").html("You have submitted an invalid response for question " + i + ".");
    //                 $("#feedback-catch").addClass("show");
    //                 // wait to reset display
    //                 setTimeout(function () {
    //                     $("#feedback-catch").removeClass("show");
    //                 }, 4250);
    //                 moveOn = false;
    //             }
    //         }
    //     }
    //     if (moveOn) {
    //         // all responses are logged and valid: pass onto next page
    //         // console.log("responses approved")
    //         window.location.href = nextUrl;
    //     }
    // });
}