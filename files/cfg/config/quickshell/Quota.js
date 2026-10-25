// The dashboard reports percent used. The widget only exposes percent remaining.
function parseDocument(text) {
  const document = JSON.parse(text);
  if (!document || !Array.isArray(document.accounts)
      || typeof document.generated_at !== "string"
      || !Number.isFinite(Date.parse(document.generated_at))) {
    throw new Error("Invalid quota response.");
  }

  const groups = [];
  for (const account of document.accounts) {
    if (!account || typeof account.id !== "string" || !account.id
        || typeof account.provider !== "string" || !account.provider
        || typeof account.name !== "string" || !Array.isArray(account.windows)
        || typeof account.error !== "string") {
      throw new Error("Invalid account response.");
    }
    const windows = account.windows.map(item => {
      if (!item || typeof item.label !== "string") {
        throw new Error("Invalid quota window.");
      }
      const percent = item.percent;
      const reset = typeof item.resets_at === "string" ? Date.parse(item.resets_at) : NaN;
      return {
        label: item.label,
        remaining: typeof percent === "number" && Number.isFinite(percent)
          ? Math.max(0, Math.min(100, 100 - percent)) : null,
        resetAt: Number.isFinite(reset) ? reset : null
      };
    });
    const credits = account.resets ? account.resets.available : null;
    const normalized = {
      id: account.id,
      name: account.name,
      priority: Number.isInteger(account.priority) ? account.priority : null,
      error: account.error,
      windows: windows,
      resetCredits: Number.isInteger(credits) && credits >= 0 ? credits : null
    };
    let group = groups.find(item => item.provider === account.provider);
    if (!group) {
      group = {
        provider: account.provider,
        name: account.provider.charAt(0).toUpperCase() + account.provider.slice(1),
        accounts: []
      };
      groups.push(group);
    }
    group.accounts.push(normalized);
  }
  groups.sort((a, b) => a.provider.localeCompare(b.provider));
  return { generatedAt: Date.parse(document.generated_at), groups: groups };
}

function parseCredits(document) {
  if (!document || !Array.isArray(document.credits)) {
    throw new Error("Invalid reset list.");
  }
  return document.credits.map(item => {
    if (!item || typeof item.id !== "string" || !item.id) {
      throw new Error("Invalid reset credit.");
    }
    const expiry = typeof item.expires_at === "string" ? Date.parse(item.expires_at) : NaN;
    if (item.expires_at !== null && item.expires_at !== undefined && !Number.isFinite(expiry)) {
      throw new Error("Invalid credit expiry.");
    }
    return {
      id: item.id,
      title: typeof item.title === "string" ? item.title : "",
      expiresAt: Number.isFinite(expiry) ? expiry : null
    };
  });
}

function resetText(resetAt, now) {
  if (resetAt === null) return "—";
  const minutes = Math.ceil((resetAt - now) / 60000);
  if (minutes <= 0) return "Due";
  const days = Math.floor(minutes / 1440);
  const hours = Math.floor((minutes % 1440) / 60);
  const rest = minutes % 60;
  return days > 0 ? days + "d " + hours + "h"
    : hours > 0 ? hours + "h " + rest + "m" : rest + "m";
}
