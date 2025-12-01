# Test Plan

## Introduction

This document provides a basic test plan that verifies as much application
functionality as feasible.

The intention is to provide basic assurance that the application is functional,
and guard against regressions.

**The document is not intended to be an exhaustive test plan.**

## Test Plan Assumptions

This test plan assumes that the user can log in via CAS.

The test plan steps are specified using URLs for the Kubernetes "test"
namespace, as that seems to be the most useful. Unless otherwise specified,
test steps should work in the local development environment as well, when
using the "umd-lib/reciprocal-borrowing-dev-env" environment.

## Reciprocal Borrowing Test Plan

### 1) Home Page

1.1) In a web browser, go to

<https://test.borrow.btaa.org/>

The "Reciprocal Borrowing" home page will be displayed.

1.2) On the "Reciprocal Borrowing" home page, verify that:

* an environment banner appropriate to the Kubernetes namespace
  (i.e. "Test Environment") is displayed.

  **Note:** The environment banner should *not* be displayed in the production
  namepace.

* the page contains links for each of the institutions participating
  in Reciprocal Borrowing.

* the page contains two footers:

  * a "Big Ten Academic Alliance Reciprocal Borrowing" footer with three links:

    * About Reciprocal Borrowing
    * Contact Us
    * Big Ten Academic Alliance Homepage

  * a bottom footer with a "Hosted by the University of Maryland Libraries" link

### 2) Home Page - Footer links

2.1) On the "Reciprocal Borrowing" home page, left-click the
"About Reciprocal Borrowing" link in the
"Big Ten Academic Alliance Reciprocal Borrowing" footer.

 Verify that a BTTA page
(on <https://btta.org.> is displayed.

2.2) Left-click the "Back" button in the browser to return to the
"Reciprocal Borrowing" home page.

2.3) On the "Reciprocal Borrowing" home page, left-click the
"Contact Us" link in the "Big Ten Academic Alliance Reciprocal Borrowing"
footer.

Verify that this opens up an email client with a "To" address of
`support@btaa.org`.

2.4) On the "Reciprocal Borrowing" home page, left-click the
"Big Ten Academic Alliance Homepage" link in the
"Big Ten Academic Alliance Reciprocal Borrowing" footer.

Verify that the <https://btaa.org/about> page is displayed.

2.5) Left-click the "Back" button in the browser to return to the
"Reciprocal Borrowing" home page.

2.6) Left-click the "Hosted by the University of Maryland Libraries" link in
the bottom footer. Verify that the "Hosting and Technology" page is displayed).

2.7) Left-click the "Back" button in the browser to return to the
"Reciprocal Borrowing" home page.

### 3) Home Page - Eligible User

3.1) On the "Reciprocal Borrowing" home page, left-click the
"University of Maryland" link in the main content. Verify that you are
redirected to a CAS login page.

3.2) After logging in via CAS, verify that a Reciprocal Borrowing page is
displayed with user information and text indicating that the user is eligible
for borrowing. For UMD logins, the user information fields should be:

* Name - the name of the user
* Entitlement - `https://borrow.btaa.org/reciprocalborrower`
* Principal Name - the email address of the user
* Identifier - `N/A`
