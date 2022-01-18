import React from "react";
import { AppDataContext } from "./AppDataProvider";
import { CommandContext } from "./CommandProvider";
import ParticipantApp from "./ParticipantApp";
import AdminApp from "./AdminApp";

const Main: React.FC = () => {
  const [joinModal, setJoinModal] = React.useState<boolean>(false);
  const [displayName, setDisplayName] = React.useState<string>("");
  const [meetingCode, setMeetingCode] = React.useState<string>("");
  const { appType } = React.useContext(AppDataContext);
  const { joinMeeting, startMeeting } = React.useContext(CommandContext);
  return (
    <div className="App">
      {appType == "init" ? (
        <div className="splash">
          {!joinModal ? (
            <div>
              <button
                onClick={() => {
                  setJoinModal(true);
                }}
              >
                Join
              </button>
              or
              <button onClick={() => startMeeting()}>Start</button>a meeting
            </div>
          ) : (
            <div>
              <div>Display Name</div>
              <input
                type="text"
                onChange={(e) => {
                  setDisplayName(e.target.value);
                }}
              />
              <div>Meeting Code</div>
              <input
                type="text"
                onChange={(e) => {
                  setMeetingCode(e.target.value);
                }}
              />
              <button
                onClick={() => {
                  joinMeeting(displayName, meetingCode);
                }}
              >
                Join
              </button>
            </div>
          )}
        </div>
      ) : (
        ""
      )}
      {appType == "participant" ? <ParticipantApp /> : ""}
      {appType == "admin" ? <AdminApp /> : ""}
    </div>
  );
};

export default Main;
