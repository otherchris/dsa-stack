import React from "react";
import AppDataProvider from "./AppDataProvider";
import CommandProvider from "./CommandProvider";
import Main from "./Main";
import "./App.css";

function App() {
  return (
    <AppDataProvider>
      <CommandProvider>
        <Main />
      </CommandProvider>
    </AppDataProvider>
  );
}

export default App;
