const express = require("express");
const BandwidthWebRTC = require("@bandwidth/webrtc");
const uuid = require("uuid");
const dotenv = require("dotenv").config();
const app = express();
const bodyParser = require("body-parser");
app.use(bodyParser.json());
app.use(express.static("public"));

// config
const port = 3000;
const accountId = process.env.BANDWIDTH_ACCOUNT_ID;

console.log("Starting server with account id:", accountId);

// Global variables
BandwidthWebRTC.Configuration.basicAuthUserName = process.env.BANDWIDTH_USERNAME;
BandwidthWebRTC.Configuration.basicAuthPassword = process.env.BANDWIDTH_PASSWORD;
var webRTCController = BandwidthWebRTC.APIController;

// track our session ID
//  - if not a demo, these would be stored in persistant storage
let sessionId = false;

/**
 * Setup the call and pass info to the client so they can join
 */
app.get("/startCall", async (req, res) => {
  console.log("setup client client");
  try {
    // create the session
    let session_id = await getSessionId(accountId, "session-test");

    let [participant, token] = await createParticipant(accountId, uuid.v1());

    await addParticipantToSession(accountId, participant.id, session_id);
    // now that we have added them to the session, we can send back the token they need to join
    res.send({
      message: "created particpant and setup session",
      token: token,
    });
  } catch (error) {
    console.log("Failed to start the client call:", error);
    res.status(500).send({ message: "failed to set up participant" });
  }
});

/**
 * start our server
 */
app.listen(port, () => {
  console.log(`Example app listening on port  http://localhost:${port}`);
});

// ------------------------------------------------------------------------------------------
// All the functions for interacting with Bandwidth WebRTC services below here
//
/**
 * @param session_id
 */
function saveSessionId(session_id) {
  // saved globally for simplicity of demo
  sessionId = session_id;
}
/**
 * Return the session id
 * This will either create one via the API, or return the one already created for this session
 * @param account_id
 * @param tag
 * @return a Session id
 */
async function getSessionId(account_id, tag) {
  // check if we've already created a session for this call
  //  - this is a simplification we're doing for this demo
  if (sessionId) {
    return sessionId;
  }

  console.log("No session found, creating one");
  // otherwise, create the session
  // tags are useful to audit or manage billing records
  var sessionBody = new BandwidthWebRTC.Session({ tag: tag });

  try {
    let sessionResponse = await webRTCController.createSession(
      account_id,
      sessionBody
    );
    // saves it for future use, this would normally be stored with meeting/call/appt details
    saveSessionId(sessionResponse.id);

    return sessionResponse.id;
  } catch (error) {
    console.log("Failed to create session:", error);
    throw new Error(
      "Error in createSession, error from BAND:" + error.errorMessage
    );
  }
}

/**
 *  Create a new participant
 * @param account_id
 * @param tag to tag the participant with, no PII should be placed here
 * @return list: (a Participant json object, the participant token)
 */
async function createParticipant(account_id, tag) {
  // create a participant for this client user
  var participantBody = new BandwidthWebRTC.Participant({
    tag: tag,
    publishPermissions: ["AUDIO", "VIDEO"],
  });

  try {
    let createResponse = await webRTCController.createParticipant(
      account_id,
      participantBody
    );

    return [createResponse.participant, createResponse.token];
  } catch (error) {
    console.log("failed to create Participant", error);
    throw new Error(
      "Failed to createParticipant, error from BAND:" + error.errorMessage
    );
  }
}

/**
 * @param account_id The id for this account
 * @param participant_id a Participant id
 * @param session_id The session to add this participant to
 */
async function addParticipantToSession(account_id, participant_id, session_id) {
  var body = new BandwidthWebRTC.Subscriptions({ sessionId: session_id });

  try {
    await webRTCController.addParticipantToSession(
      account_id,
      session_id,
      participant_id,
      body
    );
  } catch (error) {
    console.log("Error on addParticipant to Session:", error);
    throw new Error(
      "Failed to addParticipantToSession, error from BAND:" + error.errorMessage
    );
  }
}
