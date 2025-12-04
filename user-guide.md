# Bank Loan Management System – User Guide

This guide explains how an end‑user can work with the Bank Loan Management System via the web interface.

The screenshots are not included, but all pages share the same layout:

- A sidebar on the left with navigation links.
- The main content area on the right.
- Notification banners at the top of the content area for success/error messages.

On first start the system creates sample clients and loans so that the UI is immediately populated.

## 1. Accessing the Application

The application is a Flask web app.

- **Kubernetes / AWS deployment:**  
  Open the URL printed in the CI/CD pipeline logs, for example:  
  `http://<ALB_DNS>/`
- **Local run (developer):**  
  If you run `Website/app.py` locally, open:  
  `http://localhost:5000/`

The browser will show the **Home** page with a short welcome message.

## 2. Navigation Overview

The left‑side menu contains the main entries:

- **Home** – welcome screen and entry point.
- **View Clients** – list of all clients.
- **Add Client** – form for registering a new client.
- **View Loans** – list of all loans.
- **Add Loan** – form for creating a new loan.
- **Bank** – bank dashboard (treasury and payments).

You can switch between pages at any time using this sidebar.

## 3. Working with Clients

### 3.1 View all clients

1. Click **View Clients** in the sidebar.  
2. The table shows one row per client:
   - **ID** – numeric client ID.
   - **Name** – full name.
   - **Email** – contact email.
   - **Phone** – phone number.
3. Use the **Details** button in each row to open the full profile.

### 3.2 Client details and loans

1. On the **Clients** page, click **Details** for a specific client.  
2. The page shows:
   - Client **name**, **email** and **phone**.
   - A **Loans** table (if the client has any loans).
3. For each loan you can see:
   - **ID**, **Amount**, **Rate**, **Term**, **Status**.
   - An **Amortization** button to open the repayment schedule for that loan.

### 3.3 Add a new client

1. Click **Add Client** in the sidebar.  
2. Fill in the form:
   - **Name** – cannot be empty.
   - **Email** – must contain `@` and `.` and be at least 5 characters.
   - **Phone** – digits only, 9–15 characters.
3. Click **Add Client**.
4. If there are validation errors, they appear in a red banner at the top; correct the input and submit again.
5. On success, you will be redirected back to the **Clients** page and see a green success message.

## 4. Working with Loans

### 4.1 View all loans

1. Click **View Loans** in the sidebar.  
2. The table shows:
   - **ID** – loan ID.
   - **Client** – client name.
   - **Amount** – principal amount.
   - **Rate (%)** – annual interest rate.
   - **Term** – duration in months.
3. Click **Amortization** to see the detailed schedule for a specific loan.

### 4.2 Add a new loan

1. Click **Add Loan** in the sidebar.  
2. Fill in the loan form:
   - **Client ID** – numeric ID of an existing client (from the Clients page).
   - **Amount** – positive number (loan principal).
   - **Interest Rate (%)** – non‑negative annual interest rate.
   - **Term (Months)** – positive integer number of months.
   - **Status** – general loan status (choose typically **Active** for new loans).
3. Click **Add Loan**.
4. If the data is invalid (e.g., unknown client ID, negative amount, etc.), errors are shown in a red banner.
5. On success, you are redirected to **View Loans** and the new loan appears in the table.

### 4.3 View amortization schedule

1. From **View Loans** or **Client Details**, click **Amortization** for a loan.  
2. The **Amortization Schedule** page shows:
   - Basic loan info (client, amount, rate, term).
   - A table with one row per month:
     - **Month** – installment number.
     - **Payment** – total monthly payment.
     - **Principal** – part of the payment that reduces the principal.
     - **Interest** – part of the payment that pays interest.
     - **Balance** – remaining principal after the payment.
     - **Status** – **Pending** or **Paid**.

This schedule updates as the bank collects payments (see Bank dashboard below).

## 5. Bank Dashboard (Treasury and Payments)

Click **Bank** in the sidebar to open the bank dashboard.

The page contains:

- **Treasury Balance** – total money already collected by the bank.
- **Total Loan Balance** – remaining unpaid loan balance (sum over all active loans).
- **Due This Round** – sum of the next due installment for each client (one payment per client).
- **Next Payments** – a list of clients and the amount each is expected to pay in the next collection round.

### 5.1 Collecting payments – “Take money!”

At the bottom of the Bank page you see a red button:

- **Take money!** – simulates one collection round.

When you click this button:

1. For each client, the system finds the next **pending** payment in that client’s loan schedule.
2. That payment is marked as **paid**.
3. The amount is added to the **Treasury Balance**.
4. The “Due This Round” and “Next Payments” values update to reflect the next upcoming installments.

You can repeat this action multiple times to simulate several monthly collection rounds.

## 6. Data Persistence

- The system stores data in JSON files in the application’s data directory.
- On the very first run, if no files are found, the app creates dummy data (sample clients and loans).
- After that, any clients or loans you add, and all payment statuses, are saved and reused across restarts.

As a normal user you interact only through the web UI; no direct file access is required.

