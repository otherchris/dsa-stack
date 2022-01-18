import React, {
  createContext,
  FC,
  useContext,
  useEffect,
  useState,
} from "react";
import { AppDataContext } from "./AppDataProvider";
import {
  messageHandler,
  joinMeetingFunc,
  startMeetingFunc,
  createStackFunc,
  openStackFunc,
  closeStackFunc,
  joinStackFunc,
} from "./commandLib";

interface Commands {
  startMeeting: () => void;
  joinMeeting: (a: string, b: string) => void;
  createStack: (a: string) => void;
  joinStack: (a: string) => void;
  openStack: (a: string) => void;
  closeStack: (a: string) => void;
}

const noop = () => {};

const initCommands = {
  startMeeting: noop,
  joinMeeting: noop,
  createStack: noop,
  joinStack: noop,
  openStack: noop,
  closeStack: noop,
};

export const CommandContext = React.createContext<Commands>(initCommands);

const CommandProvider: FC = ({ children }) => {
  const appDataContext = useContext(AppDataContext);
  const [socket, setSocket] = useState<WebSocket>(
    new WebSocket("ws://localhost:8000/ws/")
  );
  useEffect(() => {
    socket.onmessage = (m) => messageHandler(m, appDataContext);
  }, []);
  const commands = {
    ...initCommands,
    startMeeting: startMeetingFunc.bind(this, socket, appDataContext),
    joinMeeting: joinMeetingFunc.bind(this, socket, appDataContext),
    createStack: createStackFunc.bind(this, socket, appDataContext),
    joinStack: joinStackFunc.bind(this, socket, appDataContext),
    openStack: openStackFunc.bind(this, socket, appDataContext),
    closeStack: closeStackFunc.bind(this, socket, appDataContext),
  };
  return (
    <CommandContext.Provider value={commands}>
      {children}
    </CommandContext.Provider>
  );
};

export default CommandProvider;
