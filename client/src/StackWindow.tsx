import React, { FC } from "react";
import { Stack } from "./types";
import StackContainer from "./StackContainer";

const StackWindow: FC<{ stacks: Array<Stack>; title: string }> = ({
  stacks,
  title,
}) => {
  const stackContainers = stacks.map((s) => <StackContainer stack={s} admin />);
  return (
    <div className="stack-window">
      {title}
      {stackContainers}
    </div>
  );
};

export default StackWindow;
