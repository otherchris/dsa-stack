import React from "react";
import { Participant, Stack } from "./types";

interface StackTileProps {
  stack: Stack;
  participant?: Participant;
}

const StackTile: React.FC<StackTileProps> = ({
  stack: { id },
  participant,
}) => {
  if (participant)
    return <div className="stack-tile">{participant.displayName}</div>;
  return <div></div>;
};

export default StackTile;
