pragma Singleton

import Quickshell
import QtQuick
import "Quota.js" as Quota

Singleton {
  id: root

  enum State { Closed, Loading, Ready, Confirming, Submitting, Complete, Failed }

  property int state: ResetData.Closed
  property string accountId: ""
  property var credits: []
  property var selected: null
  property string error: ""
  property var request: null
  readonly property bool busy: state === ResetData.Loading || state === ResetData.Submitting

  function show(id) {
    if (state === ResetData.Confirming || state === ResetData.Submitting
        || (accountId === id && state !== ResetData.Closed)) return;
    close();
    accountId = id;
    state = ResetData.Loading;
    send("GET", "/api/quota/resets?account=" + encodeURIComponent(id), null);
  }

  function close() {
    // A hidden panel must not abort a reset that the user already confirmed.
    if (state === ResetData.Submitting) return;
    const pending = request;
    request = null;
    deadline.stop();
    if (pending) pending.abort();
    state = ResetData.Closed;
    accountId = "";
    credits = [];
    selected = null;
    error = "";
  }

  function select(credit) {
    if (state !== ResetData.Ready) return;
    selected = credit;
    state = ResetData.Confirming;
  }

  function cancel() {
    if (state !== ResetData.Confirming) return;
    selected = null;
    state = ResetData.Ready;
  }

  function consume() {
    if (state !== ResetData.Confirming || !selected) return;
    state = ResetData.Submitting;
    send("POST", "/api/quota/reset", {
      account: accountId, credit: selected.id, confirm: true
    });
  }

  function send(method, path, body) {
    const pending = new XMLHttpRequest();
    const mutation = method === "POST";
    request = pending;
    pending.onreadystatechange = () => {
      if (pending.readyState !== XMLHttpRequest.DONE || root.request !== pending) return;
      deadline.stop();
      root.request = null;
      let document;
      try {
        document = JSON.parse(pending.responseText);
        if (pending.status !== 200) {
          throw new Error(document && typeof document.error === "string" ? document.error
            : "Request failed. Check the dashboard service.");
        }
        if (mutation) {
          if (!document || document.ok !== true) throw new Error("Could not confirm the reset. Check the account before another attempt.");
          root.credits = [];
          root.selected = null;
          root.state = ResetData.Complete;
          QuotaData.refresh(true);
        } else {
          root.credits = Quota.parseCredits(document);
          root.state = ResetData.Ready;
        }
      } catch (failure) {
        root.error = pending.status === 0 || !document
          ? mutation ? "Could not confirm the reset. Check the account before another attempt."
            : "Could not read reset credits. Check the dashboard service."
          : failure.message;
        root.state = ResetData.Failed;
      }
    };
    pending.open(method, "http://127.0.0.1:8770" + path);
    if (mutation) pending.setRequestHeader("Content-Type", "application/json");
    deadline.start();
    pending.send(mutation ? JSON.stringify(body) : null);
  }

  Timer {
    id: deadline
    interval: 30000
    onTriggered: {
      const mutation = root.state === ResetData.Submitting;
      const pending = root.request;
      root.request = null;
      if (pending) pending.abort();
      root.error = mutation ? "Could not confirm the reset. Check the account before another attempt."
        : "Reset list request timed out.";
      root.state = ResetData.Failed;
    }
  }
}
