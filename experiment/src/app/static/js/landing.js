// add vis example
let filepath = "../img/" + routeVars.cond + "-5_sd_0.228_odds" + extension();
// console.log("loading stim", filepath);
$("#stim").attr("src", filepath);

// determine file extension for stimulus
function extension() {
    let reHOPs = /HOPs/;
    if (reHOPs.test(routeVars.cond)) {
        return ".gif";
    } else {
        return ".svg";
    }
}