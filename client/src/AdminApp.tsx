import React, { useContext, useState } from "react";
import { AppDataContext } from "./AppDataProvider";
import { CommandContext } from "./CommandProvider";
import StackWindow from "./StackWindow";

const AdminApp: React.FC<{}> = () => {
  const {
    meetingData: { code, stacks },
  } = useContext(AppDataContext);
  const { createStack } = useContext(CommandContext);
  const [createStackModal, setCreateStackModal] = useState<boolean>(false);
  const [newStackName, setNewStackName] = useState<string>("");
  const openStacks = stacks.filter((s) => s.state === "open");
  const otherStacks = stacks.filter((s) => s.state !== "open");
  return (
    <div>
      <div className="adminScreenWarning">
        You will need a wider screen to use the meeting admin app!
      </div>
      {createStackModal ? (
        <div className="splash">
          Stack Name:
          <input
            type="text"
            onChange={(e) => setNewStackName(e.target.value)}
          />
          <button
            onClick={() => {
              createStack(newStackName);
              setCreateStackModal(false);
            }}
          >
            Create Stack
          </button>
        </div>
      ) : (
        <div className="adminContainer">
          <div className="header">
            <span>Meeting: {code}</span>
            <button onClick={() => setCreateStackModal(true)}>
              Create Stack
            </button>
          </div>
          <div className="stackWindowContainer">
            <StackWindow stacks={openStacks} title="Open Stacks" />
            <StackWindow stacks={otherStacks} title="Other Stacks" />
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminApp;
