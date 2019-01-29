// determine file extension for stimulus
let reHOPs = /HOPs/;
let extension
if (reHOPs.test(config.cond)) {
    extension = ".gif";
} else {
    extension = ".svg";
}
// set src of stimulus img
const filepath = "../img/" + config.cond + "-high sd, 0.25 odds" + extension;
$("#stim").attr("src", filepath);

// update slider labels
console.log($("#prob").attr("value")) // need reactive labels on slider, also need to push values to db on navigation to next page