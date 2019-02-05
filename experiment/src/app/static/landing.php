<!DOCTYPE html>

<html>

<head>
    <meta charset="utf-8">
    <script src="https://code.jquery.com/jquery-2.1.1.js"></script>
    <script src="https://code.jquery.com/ui/1.11.1/jquery-ui.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script>
    <link href='https://fonts.googleapis.com/css?family=Lato:400,300,300italic,100italic,400italic,700' rel='stylesheet' type='text/css'>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>

    <?php
        error_reporting(0);
        @ini_set('display_errors', 0);
        $workerId = $_GET['workerId'];
        $assignmentId = $_GET['assignmentId'];
        $cond = $_GET['cond'];
        $formAction = "https://workersandbox.mturk.com/mturk/externalSubmit";
        //$formAction = "https://www.mturk.com/mturk/externalSubmit";
    ?>
</head>

<body>
    <form style="position: static;" name="myform" id="myform" method="post" action="<?php echo $formAction; ?>">
        <input type="hidden" name="workerId" value="<?php echo $workerId; ?>">
        <input type="hidden" name="assignmentId" value="<?php echo $assignmentId; ?>">
        <input type="hidden" name="cond" value="<?php echo $cond; ?>">
        <!-- <input type="hidden" name="somestring" id="somestring" value="this is data gathered in study sent back to MTurk"> -->
        <div id="content" class="container-fluid mx-auto" style="width: 800px;">
            <div id="desc">
                <center><h2>"Betting on Outcomes of a Simulated Game"</h2></center>
                <p>In this HIT, you will bet on the outcomes of a game where two teams compete. For each bet you place, you will be shown a chart of the past scores for each of the competing teams.</p>
                <p>For example, you might see this chart:</p>
                <img id="stim"/>
                <p>You will be assigned to bet on one of the two teams. You will report an estimate of the probability that your team will win. Then you will allocate some portion of a 50 cent budget to bet.</p> 
                <p>On the next page, we describe the payoff scheme for the betting task. You will bet on 20 rounds of the game. The sum of your funds across all rounds is your bonus for completing the HIT. Your task is to maximize your bonus by basing your bets on the information presented in the charts. After placing your bets, you will complete a brief questionnaire. The HIT should take no more than 40 minutes.</p>
                <p><b>You will receive $2.00 for your work on this HIT in addition to your bonus. If you bet well, your expected bonus is about $8.</b></p>
                <p>This HIT is part of a research project. We are interested in how well you do on the task without the help of other resources.</p>
                <center><a href="http://127.0.0.1:5000/1_instructions?workerId=<?php echo $workerId; ?>&assignmentId=<?php echo $assignmentId; ?>&cond=<?php echo $cond; ?>">Start HIT in New Tab</a></center>
            </div>
            <div id="submission" style="padding-top: 40px;">
                <center>
                <p>When you have finished the HIT, enter the token you are given in the text box below, then press Submit!</p>
                <input type="text" name="token" id="token" placeholder="your token here">
                <br/><br/>
                <input type="submit" id="submitbutton" class="btn btn-default" value="Submit">
                </center>
            </div>

        </div>
        
    </form>
</body>
</html>