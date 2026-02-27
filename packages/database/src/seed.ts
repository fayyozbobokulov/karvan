import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";
import { unitDefinitions, flowDefinitions, users } from "./schema";
import type { FlowNode } from "./schema";

async function seed() {
  const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
  });
  const db = drizzle(pool);

  console.log("Seeding unit definitions...");

  // ---------------------------------------------------------------------------
  // Seed Users (upsert — skip if they already exist)
  // ---------------------------------------------------------------------------
  const seedUsers = [
    {
      id: "clerk-uuid",
      name: "John Smith",
      role: "clerk",
      email: "clerk@gov.local",
    },
    {
      id: "reviewer-uuid",
      name: "Jane Doe",
      role: "reviewer",
      email: "reviewer@gov.local",
    },
    {
      id: "head-uuid",
      name: "Dr. Adams",
      role: "department_head",
      email: "head@gov.local",
    },
    {
      id: "director-uuid",
      name: "Dir. Bates",
      role: "director",
      email: "director@gov.local",
    },
    {
      id: "minister-uuid",
      name: "Min. Clark",
      role: "signatory",
      email: "signatory@gov.local",
    },
    {
      id: "accountant-uuid",
      name: "Ms. Davis",
      role: "accountant",
      email: "accountant@gov.local",
    },
    {
      id: "hr-uuid",
      name: "Mr. Evans",
      role: "hr_officer",
      email: "hr@gov.local",
    },
    {
      id: "secretary-uuid",
      name: "Ms. Fisher",
      role: "secretary",
      email: "secretary@gov.local",
    },
  ];

  for (const user of seedUsers) {
    await db
      .insert(users)
      .values(user)
      .onConflictDoNothing({ target: users.id });
  }
  console.log(`  ✓ ${seedUsers.length} users seeded`);

  // ---------------------------------------------------------------------------
  // Unit Definitions — 30+ reusable units across all 8 types
  // ---------------------------------------------------------------------------
  const units: (typeof unitDefinitions.$inferInsert)[] = [
    // ── DOCUMENT units ─────────────────────────────────────────
    {
      id: "doc:business_trip_plan",
      type: "DOCUMENT",
      name: "Business Trip Plan",
      description:
        "Initial trip planning document with destination, dates, and cost estimate",
      config: {
        template: "business_trip_plan",
        fields: [
          "destination",
          "dateFrom",
          "dateTo",
          "estimatedCost",
          "purpose",
        ],
        creator: "initiator",
      },
    },
    {
      id: "doc:business_trip_notice",
      type: "DOCUMENT",
      name: "Business Trip Notice",
      description: "Official notice for a business trip",
      config: {
        template: "business_trip_notice",
        fields: ["tripPlanRef", "approvedBy"],
        creator: "initiator",
      },
    },
    {
      id: "doc:business_trip_order",
      type: "DOCUMENT",
      name: "Business Trip Order",
      description: "Formal order document for the trip",
      config: {
        template: "business_trip_order",
        fields: ["orderNumber", "tripDetails"],
        creator: "responsible_person",
      },
    },
    {
      id: "doc:business_trip_certificate",
      type: "DOCUMENT",
      name: "Business Trip Certificate",
      description: "Certificate confirming trip completion",
      config: { template: "business_trip_certificate", autoGenerate: true },
    },
    {
      id: "doc:leave_request",
      type: "DOCUMENT",
      name: "Leave Request",
      description: "Employee leave request form",
      config: {
        template: "leave_request",
        fields: ["leaveType", "dateFrom", "dateTo", "reason"],
        creator: "initiator",
      },
    },
    {
      id: "doc:incoming_letter",
      type: "DOCUMENT",
      name: "Incoming Letter",
      description: "External incoming correspondence",
      config: {
        template: "incoming_letter",
        fields: ["sender", "subject", "receivedDate", "urgency"],
        creator: "secretary",
      },
    },
    {
      id: "doc:procurement_request",
      type: "DOCUMENT",
      name: "Procurement Request",
      description: "Request for procurement of goods or services",
      config: {
        template: "procurement_request",
        fields: ["items", "totalAmount", "vendor", "justification"],
        creator: "initiator",
      },
    },
    {
      id: "doc:procurement_order",
      type: "DOCUMENT",
      name: "Procurement Order",
      description: "Official purchase order",
      config: {
        template: "procurement_order",
        fields: ["orderNumber", "vendor", "items", "totalAmount"],
        creator: "procurement_officer",
      },
    },

    // ── ACTION units ───────────────────────────────────────────
    {
      id: "action:sign_self",
      type: "ACTION",
      name: "Self-Sign",
      description: "The initiator signs their own document",
      config: {
        allowedActions: ["SIGN"],
        requiresComment: false,
        assignee: "initiator",
      },
    },
    {
      id: "action:sign",
      type: "ACTION",
      name: "Sign Document",
      description: "Official signature action with reject/change options",
      config: {
        allowedActions: ["SIGN", "REJECT", "REQUEST_CHANGE"],
        requiresComment: true,
        timeout: "168h",
      },
    },
    {
      id: "action:agree",
      type: "ACTION",
      name: "Agreement Review",
      description: "Agreement party reviews and approves",
      config: {
        allowedActions: ["AGREE", "REJECT", "REQUEST_CHANGE"],
        requiresComment: true,
        timeout: "72h",
      },
    },
    {
      id: "action:approve",
      type: "ACTION",
      name: "Approve",
      description: "General approval action",
      config: {
        allowedActions: ["APPROVE", "REJECT", "REQUEST_CHANGE"],
        requiresComment: true,
        timeout: "48h",
      },
    },
    {
      id: "action:acknowledge",
      type: "ACTION",
      name: "Acknowledge Receipt",
      description: "Acknowledge receipt of a document or task",
      config: {
        allowedActions: ["ACKNOWLEDGE"],
        requiresComment: false,
        timeout: "24h",
      },
    },

    // ── TASK units ─────────────────────────────────────────────
    {
      id: "task:prepare_document",
      type: "TASK",
      name: "Prepare Document",
      description: "Manual task to prepare a document",
      config: { deadline: "72h" },
    },
    {
      id: "task:disburse_funds",
      type: "TASK",
      name: "Disburse Funds",
      description: "Accountant issues funds",
      config: { assignee: "accountant", deadline: "48h" },
    },
    {
      id: "task:hr_process",
      type: "TASK",
      name: "HR Processing",
      description: "HR sends documents for signatures and processing",
      config: { assignee: "hr_officer", deadline: "72h" },
    },
    {
      id: "task:register_incoming",
      type: "TASK",
      name: "Register Incoming Document",
      description: "Secretary registers incoming correspondence",
      config: { assignee: "secretary", deadline: "24h" },
    },
    {
      id: "task:review_and_assign",
      type: "TASK",
      name: "Review and Assign",
      description: "Review document and assign to responsible party",
      config: { deadline: "48h" },
    },
    {
      id: "task:execute_resolution",
      type: "TASK",
      name: "Execute Resolution",
      description: "Execute the assigned resolution/task",
      config: { deadline: "120h" },
    },
    {
      id: "task:procurement_evaluation",
      type: "TASK",
      name: "Evaluate Procurement",
      description: "Evaluate procurement request and prepare order",
      config: { assignee: "procurement_officer", deadline: "96h" },
    },

    // ── CONDITION units ────────────────────────────────────────
    {
      id: "cond:has_agreement_parties",
      type: "CONDITION",
      name: "Has Agreement Parties?",
      description: "Check if agreement parties are assigned",
      config: { expression: "has_agreement_parties" },
    },
    {
      id: "cond:action_result",
      type: "CONDITION",
      name: "Check Action Result",
      description: "Branch based on the previous action result",
      config: { expression: "action_result" },
    },
    {
      id: "cond:amount_threshold",
      type: "CONDITION",
      name: "Amount Threshold Check",
      description: "Check if amount exceeds threshold",
      config: { expression: "amount_threshold", threshold: 100000 },
    },
    {
      id: "cond:urgency_check",
      type: "CONDITION",
      name: "Urgency Check",
      description: "Check if document is marked urgent",
      config: { expression: "urgency_check" },
    },

    // ── NOTIFICATION units ─────────────────────────────────────
    {
      id: "notify:inform",
      type: "NOTIFICATION",
      name: "Send Notification",
      description: "General notification to a role",
      config: { channel: ["portal"], template: "general_notification" },
    },
    {
      id: "notify:flow_complete",
      type: "NOTIFICATION",
      name: "Flow Complete Notification",
      description: "Notify that the flow has completed",
      config: { channel: ["portal", "email"], template: "flow_complete" },
    },
    {
      id: "notify:rejection",
      type: "NOTIFICATION",
      name: "Rejection Notification",
      description: "Notify that a request was rejected",
      config: { channel: ["portal", "email"], template: "rejection" },
    },
    {
      id: "notify:changes_requested",
      type: "NOTIFICATION",
      name: "Changes Requested Notification",
      description: "Notify that changes are requested",
      config: { channel: ["portal"], template: "changes_requested" },
    },

    // ── AUTOMATION units ───────────────────────────────────────
    {
      id: "auto:generate_document",
      type: "AUTOMATION",
      name: "Generate Document",
      description: "Auto-generate a document from template",
      config: { handler: "generateDocumentFromTemplate" },
    },
    {
      id: "auto:archive",
      type: "AUTOMATION",
      name: "Archive Documents",
      description: "Archive all documents in the flow",
      config: { handler: "archiveDocuments" },
    },
    {
      id: "auto:register_number",
      type: "AUTOMATION",
      name: "Generate Registry Number",
      description: "Generate an official registry number",
      config: { handler: "generateRegistryNumber" },
    },
    {
      id: "auto:validate_fields",
      type: "AUTOMATION",
      name: "Validate Document Fields",
      description: "Validate that all required fields are filled",
      config: { handler: "validateDocumentFields" },
    },

    // ── GATE units ─────────────────────────────────────────────
    {
      id: "gate:wait_all",
      type: "GATE",
      name: "Wait for All",
      description: "Wait for all parallel branches to complete",
      config: { mode: "all" },
    },
    {
      id: "gate:wait_any",
      type: "GATE",
      name: "Wait for Any",
      description: "Continue when any parallel branch completes",
      config: { mode: "any" },
    },

    // ── PARALLEL units ─────────────────────────────────────────
    {
      id: "parallel:post_sign_tasks",
      type: "PARALLEL",
      name: "Post-Signing Parallel Tasks",
      description: "Launch multiple tasks after document signing",
      config: {},
    },
    {
      id: "parallel:multi_approval",
      type: "PARALLEL",
      name: "Parallel Approvals",
      description: "Multiple approvals running simultaneously",
      config: {},
    },
  ];

  for (const unit of units) {
    await db
      .insert(unitDefinitions)
      .values(unit)
      .onConflictDoNothing({ target: unitDefinitions.id });
  }
  console.log(`  ✓ ${units.length} unit definitions seeded`);

  // ---------------------------------------------------------------------------
  // Flow Definitions — 4 flow templates
  // ---------------------------------------------------------------------------

  // ── 1. Business Trip Flow ──────────────────────────────────
  const businessTripGraph: FlowNode[] = [
    {
      id: "1",
      unit: "doc:business_trip_plan",
      label: "Create Trip Plan",
      next: ["2"],
    },
    {
      id: "2",
      unit: "action:sign_self",
      label: "Sign Plan (Self)",
      config: { assignee: "initiator" },
      next: ["3"],
    },
    {
      id: "3",
      unit: "doc:business_trip_notice",
      label: "Create Trip Notice",
      next: ["4"],
    },
    {
      id: "4",
      unit: "cond:has_agreement_parties",
      label: "Has Agreement Parties?",
      next: { true: ["5"], false: ["6"] },
    },
    {
      id: "5",
      unit: "action:agree",
      label: "Agreement Party Reviews",
      config: { assignee: "agreement_party" },
      next: ["6"],
    },
    {
      id: "6",
      unit: "action:sign",
      label: "Main Signer Reviews",
      config: { assignee: "head_signer" },
      next: ["7"],
    },
    {
      id: "7",
      unit: "cond:action_result",
      label: "Signer Decision?",
      next: { SIGN: ["8"], REJECT: ["R1"], REQUEST_CHANGE: ["RC1"] },
    },
    {
      id: "8",
      unit: "task:prepare_document",
      label: "Prepare Trip Order",
      config: {
        assignee: "responsible_person",
        produces: "doc:business_trip_order",
      },
      next: ["9"],
    },
    {
      id: "9",
      unit: "action:sign",
      label: "Head Signs Order",
      config: { assignee: "head_signer" },
      next: ["10"],
    },
    {
      id: "10",
      unit: "parallel:post_sign_tasks",
      label: "Launch Post-Sign Tasks",
      next: ["11", "12", "13"],
    },
    {
      id: "11",
      unit: "task:disburse_funds",
      label: "Accountant: Issue Money",
      config: { assignee: "accountant" },
      next: ["14"],
    },
    {
      id: "12",
      unit: "notify:inform",
      label: "Inform Secretary",
      config: { recipients: "secretary" },
      next: ["14"],
    },
    {
      id: "13",
      unit: "notify:inform",
      label: "Inform Plan Creator",
      config: { recipients: "initiator" },
      next: ["14"],
    },
    {
      id: "14",
      unit: "gate:wait_all",
      label: "Wait All Tasks Done",
      next: ["15"],
    },
    {
      id: "15",
      unit: "auto:generate_document",
      label: "Generate Trip Certificate",
      config: { template: "doc:business_trip_certificate" },
      next: ["16"],
    },
    {
      id: "16",
      unit: "task:hr_process",
      label: "HR Sends for Signatures",
      config: { assignee: "hr_officer" },
      next: ["17"],
    },
    {
      id: "17",
      unit: "action:sign",
      label: "Sign Certificate",
      config: { assignee: "head_signer" },
      next: ["18"],
    },
    {
      id: "18",
      unit: "notify:flow_complete",
      label: "Inform Initiator: Done",
      config: { recipients: "initiator" },
      next: ["19"],
    },
    {
      id: "19",
      unit: "auto:archive",
      label: "Archive All Documents",
      next: [],
    },
    {
      id: "R1",
      unit: "notify:rejection",
      label: "Notify: Rejected",
      config: { recipients: "initiator", message: "Trip request rejected" },
      next: [],
      isTerminal: true,
      isError: true,
    },
    {
      id: "RC1",
      unit: "notify:changes_requested",
      label: "Notify: Changes Requested",
      config: { recipients: "initiator" },
      next: ["3"],
      isLoop: true,
    },
  ];

  // ── 2. Leave Request Flow ──────────────────────────────────
  const leaveRequestGraph: FlowNode[] = [
    {
      id: "1",
      unit: "doc:leave_request",
      label: "Create Leave Request",
      next: ["2"],
    },
    {
      id: "2",
      unit: "action:sign_self",
      label: "Sign Request (Self)",
      config: { assignee: "initiator" },
      next: ["3"],
    },
    {
      id: "3",
      unit: "action:approve",
      label: "Department Head Approves",
      config: { assignee: "department_head" },
      next: ["4"],
    },
    {
      id: "4",
      unit: "cond:action_result",
      label: "Approval Decision?",
      next: { APPROVE: ["5"], REJECT: ["R1"], REQUEST_CHANGE: ["RC1"] },
    },
    {
      id: "5",
      unit: "task:hr_process",
      label: "HR Processes Leave",
      config: { assignee: "hr_officer" },
      next: ["6"],
    },
    {
      id: "6",
      unit: "notify:flow_complete",
      label: "Notify: Leave Approved",
      config: { recipients: "initiator" },
      next: ["7"],
    },
    {
      id: "7",
      unit: "auto:archive",
      label: "Archive",
      next: [],
    },
    {
      id: "R1",
      unit: "notify:rejection",
      label: "Notify: Leave Rejected",
      config: { recipients: "initiator" },
      next: [],
      isTerminal: true,
      isError: true,
    },
    {
      id: "RC1",
      unit: "notify:changes_requested",
      label: "Notify: Changes Needed",
      config: { recipients: "initiator" },
      next: ["1"],
      isLoop: true,
    },
  ];

  // ── 3. Incoming Letter Flow (Kiruvchi hujjat) ─────────────
  //
  // Step 1: Chancellery creates and registers the document
  // Step 2: Chancellery sends to Manager → Manager signs with resolution
  // Step 3: Manager puts resolution and creates tasks for staff
  // Step 4: Staff execute their tasks in parallel
  // Step 5: Manager/Controller reviews staff responses (accept/reject)
  // Step 6: Manager responds to own task after accepting staff work
  // Step 7: Controller reviews Manager's response (accept/reject)
  //
  const incomingLetterGraph: FlowNode[] = [
    // ── Step 1: Chancellery creates document ──────────────────
    {
      id: "1",
      unit: "doc:incoming_letter",
      label: "Kanselyariya: Hujjat yaratish",
      next: ["2"],
    },
    {
      id: "2",
      unit: "auto:register_number",
      label: "Registratsiya raqami berish",
      next: ["3"],
    },

    // ── Step 2: Chancellery sends to Manager for resolution ───
    {
      id: "3",
      unit: "action:sign",
      label: "Rahbar: Rezolyutsiya qo'yib imzolash",
      config: { assignee: "manager", allowedActions: ["SIGN", "REJECT"] },
      next: ["4"],
    },
    {
      id: "4",
      unit: "cond:action_result",
      label: "Rahbar qarori?",
      next: { SIGN: ["5"], REJECT: ["R1"] },
    },

    // ── Step 3: Manager creates tasks for staff (parallel) ────
    {
      id: "5",
      unit: "parallel:post_sign_tasks",
      label: "Xodimlarga topshiriqlar",
      next: ["6", "7", "8"],
    },

    // ── Step 4: Staff execute tasks in parallel ───────────────
    {
      id: "6",
      unit: "task:execute_resolution",
      label: "Xodim 1: Topshiriqni bajarish",
      config: { assignee: "worker_1", deadline: "120h" },
      next: ["9"],
    },
    {
      id: "7",
      unit: "task:execute_resolution",
      label: "Xodim 2: Topshiriqni bajarish",
      config: { assignee: "worker_2", deadline: "120h" },
      next: ["9"],
    },
    {
      id: "8",
      unit: "task:execute_resolution",
      label: "Xodim 3: Topshiriqni bajarish",
      config: { assignee: "worker_3", deadline: "120h" },
      next: ["9"],
    },

    // Wait for all staff to complete
    {
      id: "9",
      unit: "gate:wait_all",
      label: "Barcha xodimlar tayyor bo'lishini kutish",
      next: ["10"],
    },

    // ── Step 5: Manager/Controller reviews staff responses ────
    {
      id: "10",
      unit: "action:approve",
      label: "Nazoratchi: Xodimlar javoblarini tekshirish",
      config: { assignee: "controller", allowedActions: ["APPROVE", "REJECT"] },
      next: ["11"],
    },
    {
      id: "11",
      unit: "cond:action_result",
      label: "Nazoratchi qarori?",
      next: { APPROVE: ["12"], REJECT: ["RC1"] },
    },

    // ── Step 6: Manager responds to own task ──────────────────
    {
      id: "12",
      unit: "task:execute_resolution",
      label: "Rahbar: O'z topshirig'iga javob berish",
      config: { assignee: "manager", deadline: "48h" },
      next: ["13"],
    },

    // ── Step 7: Controller reviews Manager's response ─────────
    {
      id: "13",
      unit: "action:approve",
      label: "Nazoratchi: Rahbar javobini tekshirish",
      config: { assignee: "controller", allowedActions: ["APPROVE", "REJECT"] },
      next: ["14"],
    },
    {
      id: "14",
      unit: "cond:action_result",
      label: "Yakuniy qaror?",
      next: { APPROVE: ["15"], REJECT: ["RC2"] },
    },

    // ── End: Notify and archive ───────────────────────────────
    {
      id: "15",
      unit: "notify:flow_complete",
      label: "Hujjat qayta ishlandi",
      config: {
        recipients: "secretary",
        message: "Kiruvchi hujjat yakunlandi",
      },
      next: ["16"],
    },
    {
      id: "16",
      unit: "auto:archive",
      label: "Arxivlash",
      next: [],
    },

    // ── Error/loop paths ──────────────────────────────────────
    {
      id: "R1",
      unit: "notify:rejection",
      label: "Rad etildi",
      config: { recipients: "secretary", message: "Rahbar hujjatni rad etdi" },
      next: [],
      isTerminal: true,
      isError: true,
    },
    {
      id: "RC1",
      unit: "notify:changes_requested",
      label: "Xodimlar javoblari qaytarildi",
      config: {
        recipients: "manager",
        message: "Xodimlar javoblari qabul qilinmadi",
      },
      next: ["5"],
      isLoop: true,
    },
    {
      id: "RC2",
      unit: "notify:changes_requested",
      label: "Rahbar javobi qaytarildi",
      config: {
        recipients: "manager",
        message: "Rahbar javobi qabul qilinmadi",
      },
      next: ["12"],
      isLoop: true,
    },
  ];

  // ── 4. Procurement Flow ────────────────────────────────────
  const procurementGraph: FlowNode[] = [
    {
      id: "1",
      unit: "doc:procurement_request",
      label: "Create Procurement Request",
      next: ["2"],
    },
    {
      id: "2",
      unit: "action:sign_self",
      label: "Sign Request (Self)",
      config: { assignee: "initiator" },
      next: ["3"],
    },
    {
      id: "3",
      unit: "cond:amount_threshold",
      label: "Amount > Threshold?",
      next: { true: ["4"], false: ["5"] },
    },
    {
      id: "4",
      unit: "action:approve",
      label: "Director Approves (High Value)",
      config: { assignee: "director" },
      next: ["5"],
    },
    {
      id: "5",
      unit: "action:approve",
      label: "Department Head Approves",
      config: { assignee: "department_head" },
      next: ["6"],
    },
    {
      id: "6",
      unit: "cond:action_result",
      label: "Approval Decision?",
      next: { APPROVE: ["7"], REJECT: ["R1"], REQUEST_CHANGE: ["RC1"] },
    },
    {
      id: "7",
      unit: "task:procurement_evaluation",
      label: "Procurement Officer Evaluates",
      config: { assignee: "procurement_officer" },
      next: ["8"],
    },
    {
      id: "8",
      unit: "parallel:multi_approval",
      label: "Parallel Final Approvals",
      next: ["9", "10"],
    },
    {
      id: "9",
      unit: "action:sign",
      label: "Department Head Signs Order",
      config: { assignee: "department_head" },
      next: ["11"],
    },
    {
      id: "10",
      unit: "action:sign",
      label: "Finance Signs Order",
      config: { assignee: "accountant" },
      next: ["11"],
    },
    {
      id: "11",
      unit: "gate:wait_all",
      label: "Wait for All Signatures",
      next: ["12"],
    },
    {
      id: "12",
      unit: "task:disburse_funds",
      label: "Process Payment",
      config: { assignee: "accountant" },
      next: ["13"],
    },
    {
      id: "13",
      unit: "notify:flow_complete",
      label: "Notify: Procurement Complete",
      config: { recipients: "initiator" },
      next: ["14"],
    },
    {
      id: "14",
      unit: "auto:archive",
      label: "Archive",
      next: [],
    },
    {
      id: "R1",
      unit: "notify:rejection",
      label: "Notify: Procurement Rejected",
      config: { recipients: "initiator" },
      next: [],
      isTerminal: true,
      isError: true,
    },
    {
      id: "RC1",
      unit: "notify:changes_requested",
      label: "Notify: Changes Needed",
      config: { recipients: "initiator" },
      next: ["1"],
      isLoop: true,
    },
  ];

  const flows: (typeof flowDefinitions.$inferInsert)[] = [
    {
      id: "business_trip",
      name: "Business Trip",
      description:
        "Full business trip request workflow: plan → notice → approval → order → certificate",
      icon: "✈️",
      color: "#3b82f6",
      category: "hr",
      roles: [
        "initiator",
        "agreement_party",
        "head_signer",
        "responsible_person",
        "accountant",
        "secretary",
        "hr_officer",
      ],
      graph: businessTripGraph,
      estimatedDuration: "5-10 days",
    },
    {
      id: "leave_request",
      name: "Leave Request",
      description: "Employee leave request with department head approval",
      icon: "🏖️",
      color: "#10b981",
      category: "hr",
      roles: ["initiator", "department_head", "hr_officer"],
      graph: leaveRequestGraph,
      estimatedDuration: "1-3 days",
    },
    {
      id: "incoming_letter",
      name: "Kiruvchi hujjat",
      description:
        "Kiruvchi hujjat: ro'yxatga olish → rezolyutsiya → topshiriqlar → nazorat → arxiv",
      icon: "📨",
      color: "#f59e0b",
      category: "admin",
      roles: [
        "secretary",
        "manager",
        "worker_1",
        "worker_2",
        "worker_3",
        "controller",
      ],
      graph: incomingLetterGraph,
      estimatedDuration: "5-14 days",
    },
    {
      id: "procurement",
      name: "Procurement",
      description:
        "Procurement request with threshold-based approvals and parallel signing",
      icon: "🛒",
      color: "#8b5cf6",
      category: "finance",
      roles: [
        "initiator",
        "department_head",
        "director",
        "procurement_officer",
        "accountant",
      ],
      graph: procurementGraph,
      estimatedDuration: "7-14 days",
    },
  ];

  for (const flow of flows) {
    await db
      .insert(flowDefinitions)
      .values(flow)
      .onConflictDoNothing({ target: flowDefinitions.id });
  }
  console.log(`  ✓ ${flows.length} flow definitions seeded`);

  console.log("\nSeed completed successfully!");
  await pool.end();
  process.exit(0);
}

seed().catch((err) => {
  console.error("Seed failed:", err);
  process.exit(1);
});
