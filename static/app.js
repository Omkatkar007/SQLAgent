/**
 * SQLAgent Frontend Application Logic
 * Manages API communication, dynamic rendering of SQL/Table/JSON views,
 * schema browser, prompt chips, and state.
 */

document.addEventListener("DOMContentLoaded", () => {
  // DOM Elements
  const queryForm = document.getElementById("query-form");
  const queryInput = document.getElementById("query-input");
  const submitBtn = document.getElementById("submit-btn");
  const btnSpinner = document.getElementById("btn-spinner");
  const btnText = submitBtn.querySelector(".btn-text");
  const btnIcon = submitBtn.querySelector(".btn-icon");
  const chatMessages = document.getElementById("chat-messages");
  const welcomeCard = document.getElementById("welcome-card");
  const clearBtn = document.getElementById("clear-btn");
  const modelSelect = document.getElementById("model-select");
  const limitSelect = document.getElementById("limit-select");

  // Status Elements
  const dbStatusDot = document.getElementById("db-status-dot");
  const dbStatusText = document.getElementById("db-status-text");
  const ollamaStatusDot = document.getElementById("ollama-status-dot");
  const ollamaStatusText = document.getElementById("ollama-status-text");
  const tableCountBadge = document.getElementById("table-count-badge");
  const schemaList = document.getElementById("schema-list");
  const schemaSearch = document.getElementById("schema-search");

  // Modal Elements
  const modalBackdrop = document.getElementById("modal-backdrop");
  const modalCloseBtn = document.getElementById("modal-close-btn");
  const modalTableTitle = document.getElementById("modal-table-title");
  const modalSchemaCode = document.getElementById("modal-schema-code");

  let allTables = [];

  // Initialize
  checkHealth();
  loadModels();
  loadSchema();

  // Auto-resize textarea
  queryInput.addEventListener("input", () => {
    queryInput.style.height = "auto";
    queryInput.style.height = Math.min(queryInput.scrollHeight, 140) + "px";
  });

  // Enter to submit (Shift+Enter for newline)
  queryInput.addEventListener("keydown", (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      if (queryInput.value.trim() && !submitBtn.disabled) {
        queryForm.dispatchEvent(new Event("submit"));
      }
    }
  });

  // Prompt Chips
  document.querySelectorAll(".prompt-chip").forEach((chip) => {
    chip.addEventListener("click", () => {
      const prompt = chip.getAttribute("data-prompt");
      if (prompt) {
        queryInput.value = prompt;
        queryInput.style.height = "auto";
        queryInput.focus();
        queryForm.dispatchEvent(new Event("submit"));
      }
    });
  });

  // Clear chat
  clearBtn.addEventListener("click", () => {
    chatMessages.innerHTML = "";
    if (welcomeCard) {
      chatMessages.appendChild(welcomeCard);
      welcomeCard.style.display = "block";
    }
  });

  // Schema Search Filter
  schemaSearch.addEventListener("input", (e) => {
    const term = e.target.value.toLowerCase().trim();
    const filtered = allTables.filter((t) =>
      t.name.toLowerCase().includes(term)
    );
    renderSchemaList(filtered);
  });

  // Form Submit Handler
  queryForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const question = queryInput.value.trim();
    if (!question) return;

    // Hide welcome card once first message arrives
    if (welcomeCard) {
      welcomeCard.style.display = "none";
    }

    // Append User Message
    appendUserMessage(question);
    queryInput.value = "";
    queryInput.style.height = "auto";

    // Set Loading State
    setLoading(true);
    const loadingCardId = appendLoadingCard();

    try {
      const response = await fetch("/api/query", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          question: question,
          model: modelSelect.value,
          limit: parseInt(limitSelect.value, 10),
        }),
      });

      const result = await response.json();
      removeLoadingCard(loadingCardId);
      appendAgentResponse(result);
    } catch (err) {
      removeLoadingCard(loadingCardId);
      appendAgentResponse({
        status: "error",
        question: question,
        sql_query: "",
        row_count: 0,
        data: [],
        error: "Network error: Unable to connect to SQLAgent server.",
        execution_time_ms: 0,
      });
    } finally {
      setLoading(false);
      queryInput.focus();
    }
  });

  // Health check API call
  async function checkHealth() {
    try {
      const res = await fetch("/api/health");
      const data = await res.json();

      if (data.database && data.database.connected) {
        dbStatusDot.className = "status-dot online";
        dbStatusText.textContent = data.database.database || "Connected";
      } else {
        dbStatusDot.className = "status-dot error";
        dbStatusText.textContent = "DB Error";
      }

      if (data.ollama && data.ollama.online) {
        ollamaStatusDot.className = "status-dot online";
        ollamaStatusText.textContent = "Ollama Active";
      } else {
        ollamaStatusDot.className = "status-dot error";
        ollamaStatusText.textContent = "Ollama Offline";
      }
    } catch (err) {
      dbStatusDot.className = "status-dot error";
      dbStatusText.textContent = "Offline";
      ollamaStatusDot.className = "status-dot error";
      ollamaStatusText.textContent = "Offline";
    }
  }

  // Load installed models
  async function loadModels() {
    try {
      const res = await fetch("/api/models");
      const data = await res.json();
      if (data.models && data.models.length > 0) {
        modelSelect.innerHTML = "";
        data.models.forEach((m) => {
          const opt = document.createElement("option");
          opt.value = m;
          opt.textContent = m;
          if (m === data.current_model) opt.selected = true;
          modelSelect.appendChild(opt);
        });
      }
    } catch (err) {
      console.warn("Could not fetch models:", err);
    }
  }

  // Load database schema
  async function loadSchema() {
    try {
      const res = await fetch("/api/schema");
      const data = await res.json();
      allTables = data.tables || [];
      tableCountBadge.textContent = `${allTables.length} tables`;
      renderSchemaList(allTables);
    } catch (err) {
      schemaList.innerHTML = `<div class="loading-placeholder">Failed to load schema.</div>`;
    }
  }

  // Render list of tables in sidebar
  function renderSchemaList(tables) {
    if (!tables.length) {
      schemaList.innerHTML = `<div class="loading-placeholder">No matching tables found.</div>`;
      return;
    }
    schemaList.innerHTML = "";
    tables.forEach((tbl) => {
      const item = document.createElement("div");
      item.className = "table-item";
      item.innerHTML = `
        <span class="table-name">${escapeHtml(tbl.name)}</span>
        <span class="table-cols-count">${tbl.column_count} cols</span>
      `;
      item.addEventListener("click", () => openTableModal(tbl.name));
      schemaList.appendChild(item);
    });
  }

  // Modal open table details
  async function openTableModal(tableName) {
    modalTableTitle.textContent = `Table: ${tableName}`;
    modalSchemaCode.textContent = "Loading schema...";
    modalBackdrop.style.display = "flex";

    try {
      const res = await fetch(`/api/schema/${encodeURIComponent(tableName)}`);
      const data = await res.json();
      modalSchemaCode.textContent = data.formatted || JSON.stringify(data.details, null, 2);
    } catch (err) {
      modalSchemaCode.textContent = "Error loading schema details.";
    }
  }

  // Modal close handlers
  modalCloseBtn.addEventListener("click", () => (modalBackdrop.style.display = "none"));
  modalBackdrop.addEventListener("click", (e) => {
    if (e.target === modalBackdrop) modalBackdrop.style.display = "none";
  });
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && modalBackdrop.style.display !== "none") {
      modalBackdrop.style.display = "none";
    }
  });

  // UI Appends: User message
  function appendUserMessage(text) {
    const wrapper = document.createElement("div");
    wrapper.className = "message-user";
    wrapper.innerHTML = `<div class="user-bubble">${escapeHtml(text)}</div>`;
    chatMessages.appendChild(wrapper);
    scrollToBottom();
  }

  // UI Appends: Loading card
  function appendLoadingCard() {
    const id = "loading-" + Date.now();
    const wrapper = document.createElement("div");
    wrapper.id = id;
    wrapper.className = "message-agent";
    wrapper.innerHTML = `
      <div class="agent-card">
        <div class="agent-card-header">
          <div class="header-badges">
            <span class="meta-pill info">
              <span class="spinner" style="width: 10px; height: 10px;"></span> Generating SQL...
            </span>
          </div>
        </div>
        <div class="sql-container">
          <div class="sql-label">Thinking...</div>
          <div class="sql-code" style="color: #64748b;">Consulting database schema and synthesizing query...</div>
        </div>
      </div>
    `;
    chatMessages.appendChild(wrapper);
    scrollToBottom();
    return id;
  }

  function removeLoadingCard(id) {
    const el = document.getElementById(id);
    if (el) el.remove();
  }

  // UI Appends: Agent response card
  function appendAgentResponse(result) {
    const cardId = "agent-card-" + Date.now();
    const isSuccess = result.status === "success";
    const execTime = result.execution_time_ms ? `${result.execution_time_ms} ms` : "< 1 ms";
    const rowCount = result.row_count !== undefined ? result.row_count : (result.data ? result.data.length : 0);

    const wrapper = document.createElement("div");
    wrapper.className = "message-agent";
    wrapper.id = cardId;

    let contentHtml = "";

    if (isSuccess) {
      contentHtml = `
        <div class="agent-card">
          <div class="agent-card-header">
            <div class="header-badges">
              <span class="meta-pill success">✓ SUCCESS</span>
              <span class="meta-pill info">⏱ ${execTime}</span>
              <span class="meta-pill info">📊 ${rowCount} row${rowCount === 1 ? "" : "s"}</span>
            </div>
            <div class="view-tabs">
              <button class="tab-btn active" data-view="table">Table</button>
              <button class="tab-btn" data-view="json">JSON</button>
            </div>
          </div>

          <div class="sql-container">
            <div class="sql-header">
              <span class="sql-label">Generated SQL</span>
              <button class="copy-button copy-sql-btn" title="Copy SQL">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
                <span>Copy SQL</span>
              </button>
            </div>
            <div class="sql-code">${escapeHtml(result.sql_query || "N/A")}</div>
          </div>

          <div class="data-display-container">
            <div class="view-table-container">
              ${renderDataTable(result.data)}
            </div>
            <div class="view-json-container" style="display: none;">
              <div style="display: flex; justify-content: flex-end; margin-bottom: 8px;">
                <button class="copy-button copy-json-btn">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
                  <span>Copy JSON</span>
                </button>
              </div>
              <pre class="json-code"><code>${escapeHtml(JSON.stringify(result, null, 2))}</code></pre>
            </div>
          </div>
        </div>
      `;
    } else {
      contentHtml = `
        <div class="agent-card">
          <div class="agent-card-header">
            <div class="header-badges">
              <span class="meta-pill error">✗ ERROR</span>
              <span class="meta-pill info">⏱ ${execTime}</span>
            </div>
            <div class="view-tabs">
              <button class="tab-btn active" data-view="json">JSON</button>
            </div>
          </div>
          ${result.sql_query ? `
          <div class="sql-container">
            <div class="sql-header">
              <span class="sql-label">Attempted SQL</span>
            </div>
            <div class="sql-code" style="color: #fca5a5;">${escapeHtml(result.sql_query)}</div>
          </div>` : ""}
          <div class="error-box">
            <strong>Execution Failed:</strong> ${escapeHtml(result.error || "Unknown error")}
          </div>
          <div class="data-display-container">
            <pre class="json-code"><code>${escapeHtml(JSON.stringify(result, null, 2))}</code></pre>
          </div>
        </div>
      `;
    }

    wrapper.innerHTML = contentHtml;
    chatMessages.appendChild(wrapper);

    // Bind copy and tab buttons for this card
    setupCardInteractions(wrapper, result);
    scrollToBottom();
  }

  // Setup tab switcher and copy buttons
  function setupCardInteractions(cardEl, result) {
    const tabs = cardEl.querySelectorAll(".tab-btn");
    const tableView = cardEl.querySelector(".view-table-container");
    const jsonView = cardEl.querySelector(".view-json-container");

    tabs.forEach((tab) => {
      tab.addEventListener("click", () => {
        tabs.forEach((t) => t.classList.remove("active"));
        tab.classList.add("active");
        const view = tab.getAttribute("data-view");
        if (tableView && jsonView) {
          if (view === "table") {
            tableView.style.display = "block";
            jsonView.style.display = "none";
          } else {
            tableView.style.display = "none";
            jsonView.style.display = "block";
          }
        }
      });
    });

    // Copy SQL button
    const copySqlBtn = cardEl.querySelector(".copy-sql-btn");
    if (copySqlBtn) {
      copySqlBtn.addEventListener("click", () => {
        navigator.clipboard.writeText(result.sql_query || "");
        showCopiedFeedback(copySqlBtn);
      });
    }

    // Copy JSON button
    const copyJsonBtn = cardEl.querySelector(".copy-json-btn");
    if (copyJsonBtn) {
      copyJsonBtn.addEventListener("click", () => {
        navigator.clipboard.writeText(JSON.stringify(result, null, 2));
        showCopiedFeedback(copyJsonBtn);
      });
    }
  }

  function showCopiedFeedback(btn) {
    const origHtml = btn.innerHTML;
    btn.innerHTML = `<span style="color: var(--accent-emerald);">✓ Copied!</span>`;
    setTimeout(() => {
      btn.innerHTML = origHtml;
    }, 1800);
  }

  // Render HTML data table
  function renderDataTable(data) {
    if (!data || !Array.isArray(data) || data.length === 0) {
      return `<div style="padding: 16px; color: var(--text-muted); font-size: 0.85rem; text-align: center;">No records returned by query.</div>`;
    }

    const firstRow = data[0];
    if (typeof firstRow !== "object" || firstRow === null) {
      return `<pre class="json-code"><code>${escapeHtml(JSON.stringify(data, null, 2))}</code></pre>`;
    }

    const columns = Object.keys(firstRow);

    let thHtml = columns.map((col) => `<th>${escapeHtml(col)}</th>`).join("");
    let rowsHtml = data
      .map((row) => {
        const cells = columns
          .map((col) => {
            const val = row[col];
            const displayVal = val === null ? '<em style="color: var(--text-muted);">null</em>' : escapeHtml(String(val));
            return `<td>${displayVal}</td>`;
          })
          .join("");
        return `<tr>${cells}</tr>`;
      })
      .join("");

    return `
      <div class="table-wrapper">
        <table class="result-table">
          <thead><tr>${thHtml}</tr></thead>
          <tbody>${rowsHtml}</tbody>
        </table>
      </div>
    `;
  }

  function setLoading(loading) {
    submitBtn.disabled = loading;
    if (loading) {
      btnSpinner.style.display = "inline-block";
      btnIcon.style.display = "none";
      btnText.textContent = "Querying...";
    } else {
      btnSpinner.style.display = "none";
      btnIcon.style.display = "inline-block";
      btnText.textContent = "Run Query";
    }
  }

  function scrollToBottom() {
    chatMessages.scrollTop = chatMessages.scrollHeight;
  }

  function escapeHtml(str) {
    if (!str) return "";
    return String(str)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  }
});
