# Project Management in DevTools

## Purpose

DevTools does **not include, install, or manage project-management software**.

This documentation exists to **inform users about well-known open-source project-management tools** that are widely used in professional software teams. It helps teams make informed decisions while keeping DevTools **safe, predictable, and local-machine friendly**.

---

## Important Notice

> DevTools does **not**:
>
> * Ship or load any project-management scripts
> * Install servers or software
> * Open ports or modify your system
> * Require Docker, databases, or external services

DevTools remains focused on **developer workstation productivity**, not server hosting.

---

## Why Project Management Tools Are Mentioned

Modern software teams often need:

* Issue tracking
* Sprint planning
* Backlogs and roadmaps
* Collaboration across multiple contributors

Open-source options provide:

* **Self-hosted control**
* **No SaaS lock-in**
* **Transparency and license compliance**
* **Integration with existing developer workflows**

---

## Recommended Open-Source Tools

| Tool            | Category       | Typical Use Case                      | Official Website                                           |
| --------------- | -------------- | ------------------------------------- | ---------------------------------------------------------- |
| **Taiga**       | Agile PM       | Scrum & Kanban workflows              | [https://taiga.io](https://taiga.io)                       |
| **OpenProject** | Agile Planning | Roadmaps, Gantt charts, timelines     | [https://www.openproject.org](https://www.openproject.org) |
| **Redmine**     | Issue Tracking | Classic project and issue tracking    | [https://www.redmine.org](https://www.redmine.org)         |
| **Wekan**       | Kanban Boards  | Lightweight task boards               | [https://wekan.github.io](https://wekan.github.io)         |
| **Tuleap**      | ALM Platform   | Full application lifecycle management | [https://www.tuleap.org](https://www.tuleap.org)           |

---

## Why Not SaaS?

While SaaS tools like Jira, Trello, or Asana are popular, DevTools prefers **open-source and self-hosted tools** because:

* You retain full **data ownership**
* You avoid **vendor lock-in**
* You can **audit and extend** the system
* It is **CI/CD and automation-friendly**
* It supports **offline or air-gapped environments**

---

## Comparison Cheat Sheet

| Feature           | Taiga    | OpenProject | Redmine | Wekan | Tuleap  |
| ----------------- | -------- | ----------- | ------- | ----- | ------- |
| Scrum Support     | ✅        | ✅           | ❌       | ❌     | ✅       |
| Kanban Support    | ✅        | ✅           | ✅       | ✅     | ✅       |
| Gantt / Roadmaps  | ❌        | ✅           | ✅       | ❌     | ✅       |
| Wiki / Docs       | ✅        | ✅           | ✅       | ✅     | ✅       |
| Issue Tracking    | ✅        | ✅           | ✅       | ✅     | ✅       |
| CI/CD Integration | ❌        | ❌           | ❌       | ❌     | ✅       |
| Docker Deployment | ✅        | ✅           | ✅       | ✅     | ✅       |
| License           | AGPL-3.0 | GPL-3.0     | GPL-2.0 | MIT   | GPL-2.0 |

> This cheat sheet is for **evaluation purposes only**. DevTools does not deploy any of these tools.

---

## FAQ

**Q: Do I need to install any of these tools to use DevTools?**
**A:** No. DevTools does not require or install any project-management software.

**Q: Can DevTools help me deploy these tools?**
**A:** Not directly. DevTools only provides metadata and guidance. Installation and hosting are fully manual and optional.

**Q: Why are these tools documented in DevTools?**
**A:** They serve as references for open-source, self-hosted project-management platforms for teams that want transparency, control, and compliance.

**Q: Can I automate deployment later?**
**A:** Yes. You can create scripts or CI workflows using the official docs and container images of each tool.

---

## Summary

* DevTools focuses on **developer productivity, not project servers**
* This documentation is **informational only**
* Users remain in **full control** of installation and deployment
* Open-source recommendations help teams make **informed choices**
