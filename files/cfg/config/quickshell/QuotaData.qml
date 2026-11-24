pragma Singleton

import Quickshell
import QtQuick
import "Quota.js" as Quota

Singleton {
  id: root

  // Demo mode shows one account per provider. It lives only in memory, so
  // every launch starts with it off.
  readonly property string demoAccount: "tisorlawan@gmail.com"
  property bool demo: false
  property var allGroups: []
  readonly property var groups: demo ? Quota.demoGroups(allGroups, demoAccount) : allGroups
  property var generatedAt: null
  property string error: ""
  property var request: null
  readonly property bool busy: request !== null
  readonly property int accountCount: groups.reduce((sum, group) => sum + group.accounts.length, 0)
  readonly property bool accountError: groups.some(group => group.accounts.some(account => account.error.length > 0))
  readonly property double now: clock.date.getTime()
  readonly property bool stale: generatedAt !== null && now - generatedAt > 180000

  function refresh(force) {
    if (busy) {
      if (!force) return;
      const previous = request;
      request = null;
      previous.abort();
    }
    const pending = new XMLHttpRequest();
    request = pending;
    pending.onreadystatechange = () => {
      if (pending.readyState !== XMLHttpRequest.DONE || root.request !== pending) return;
      deadline.stop();
      if (pending.status === 200) {
        try {
          const document = Quota.parseDocument(pending.responseText);
          root.allGroups = document.groups;
          root.generatedAt = document.generatedAt;
          root.error = "";
        } catch (failure) {
          root.error = "Invalid quota response. Check cli-quota.service.";
        }
      } else {
        root.error = "Quota unavailable. Check cli-quota.service.";
      }
      root.request = null;
    };
    pending.open("GET", "http://127.0.0.1:8770/api/quota");
    deadline.start();
    pending.send();
  }

  Component.onCompleted: refresh()
  Component.onDestruction: {
    const pending = request;
    request = null;
    if (pending) pending.abort();
  }

  Timer {
    interval: 60000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Timer {
    id: deadline
    // The service can query several accounts, each with a 10-second timeout.
    interval: 55000
    onTriggered: {
      const pending = root.request;
      root.request = null;
      if (pending) pending.abort();
      root.error = "Quota request timed out. Check cli-quota.service.";
    }
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}
