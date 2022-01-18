import { AppDataContextType } from "./AppDataProvider";
const messageHandler = (m: MessageEvent, a: AppDataContextType) => {
  console.log(m);
};

export default messageHandler;
