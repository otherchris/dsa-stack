import React, { useContext } from "react";
import { AppDataContext } from "./AppDataProvider";
import StackContainer from "./StackContainer";

const ParticipantApp: React.FC<{}> = () => {
  const {
    meetingData: { code, stacks },
    participantId: id,
  } = useContext(AppDataContext);
  const myStacks = stacks
    .filter((s) => s.participants.find((p) => p === id))
    .map((s) => <StackContainer stack={s} />);
  const openStacks = stacks
    .filter((s) => !s.participants.find((p) => p === id) && s.state === "open")
    .map((s) => <StackContainer stack={s} joinable />);
  return (
    <div>
      <div className="header">Meeting: {code}</div>
      <div>MYstacks{myStacks}</div>
      <div>OPENStacks{openStacks}</div>
    </div>
  );
};

export default ParticipantApp;
