import React, { useState } from "react";
import { Principal } from "@dfinity/principal";
import { token, canisterId, createActor } from "../../../declarations/token";
import { AuthClient } from "@dfinity/auth-client";

function Transfer() {

  const [recipientID, setRecipientID] = useState("");
  const [amount, setAmount] = useState("");
  const [isDisabled, setDisable] = useState(false);
  const [feedback, setFeedback] = useState("");
  const [isHidden, setHidden] = useState(true);
  
  async function handleClick() {
    setHidden(true);
    setDisable(true);
    const recipient = Principal.fromText(recipientID);
    const amountToTransfer = Number(amount);

    // For authentication to work, need to deploy app to live Internet Computer
    const authClient = await AuthClient.create();
    const identity = await authClient.getIdentity();
    const authenticatedCanister = createActor(canisterId, {
      agentOptions: {
        identity,
      },
    });
    const result = await authenticatedCanister.transfer(recipient, amountToTransfer);

    // const result = await token.transfer(recipient, amountToTransfer); // Comment out if no authentication (above)
    setFeedback(result);
    setHidden(false);
    setDisable(false);
  }

  return (
    <div className="window white">
      <div className="transfer">
        <fieldset>
          <legend>To Account:</legend>
          <ul>
            <li>
              <input
                type="text"
                id="transfer-to-id"
                value={recipientID}
                onChange={(e) => setRecipientID(e.target.value)}
              />
            </li>
          </ul>
        </fieldset>
        <fieldset>
          <legend>Amount:</legend>
          <ul>
            <li>
              <input
                type="number"
                id="amount"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
              />
            </li>
          </ul>
        </fieldset>
        <p className="trade-buttons">
          <button id="btn-transfer" onClick={handleClick} disabled={isDisabled}>
            Transfer
          </button>
        </p>
        <p hidden={isHidden}>
          {feedback}
        </p>
      </div>
    </div>
  );
}

export default Transfer;
