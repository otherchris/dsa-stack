import React, { useContext } from "react";
import { AppDataContext } from "./AppDataProvider";
import { CommandContext } from "./CommandProvider";
import { Stack } from "./types";
import StackTile from "./StackTile";

const StackContainer: React.FC<{
  stack: Stack;
  joinable?: boolean;
  admin?: boolean;
}> = ({ stack, joinable, admin }) => {
  const { id, state, displayName, participants } = stack;
  const {
    meetingData: { participants: meetingParticipants },
  } = useContext(AppDataContext);
  const { openStack, closeStack, joinStack } = useContext(CommandContext);
  const stackTiles = participants.map((p) => (
    <li id={p}>
      <StackTile
        stack={stack}
        participant={meetingParticipants.find((mp) => mp.id === p)}
      />
    </li>
  ));
  const adminTools = admin ? (
    <div>
      {state === "open" ? (
        <button onClick={() => closeStack(id)}>Close stack</button>
      ) : (
        <button onClick={() => openStack(id)}>Open stack</button>
      )}
    </div>
  ) : (
    ""
  );
  const joinButton = joinable ? (
    <button onClick={() => joinStack(id)}>Join</button>
  ) : (
    ""
  );
  return (
    <div className="stack-container">
      <div className="stack-header">
        <span className="stack-label">{displayName}</span>
        {adminTools}
        {joinButton}
      </div>
      <ul>{stackTiles}</ul>
    </div>
  );
};

export default StackContainer;
