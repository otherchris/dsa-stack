import React from "react";
import { render, screen } from "@testing-library/react";
import App from "./App";

test("renders join and learn link", () => {
  render(<App />);
  const joinElement = screen.getByText(/join/i);
  const startElement = screen.getByText(/start/i);
  expect(joinElement).toBeInTheDocument();
  expect(startElement).toBeInTheDocument();
});

test("when we click join, we see the join dialog", () => {
  render(<App />);
  const joinButton = screen.getByText(/join/i);
  joinButton.click();
  const nameElement = screen.getByText(/display name/i);
  const codeElement = screen.getByText(/meeting code/i);
  expect(nameElement).toBeInTheDocument();
  expect(codeElement).toBeInTheDocument();
});
