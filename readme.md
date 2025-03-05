# Demonstration Walkthrough: Creating User Stories and BDD Feature Files with GitHub Copilot

## Purpose
This demonstration walkthrough aims to guide you through the process of creating user stories and behavior-driven development (BDD) feature files using GitHub Copilot. The selected text highlights the prompts you can enter to walk through the demo.

## Setup
Use Copilot Edits or Edits Agent mode.

## Step-by-Step Instructions

### Step 1 - Create User Stories with No Context
1. **Prompt:** Can you create me some user stories for when a user is checking out from an ecommerce basket scenario?
2. **Template:** Use the file `template.md` as a template structure.
3. **Output:** Create each user story as a separate markdown file with a descriptive name.
4. **Folder:** Place these new user stories into a new folder called `userstories`.

### Step 2 - Create an Associated Gherkin File
1. **Prompt:** Can you create a gherkin feature document for the user story `user-story-checkout-payment.md`?
2. **Folder:** Put it in the `bdd` folder.

### Step 3 - Create Remaining Gherkin Feature Files
1. **Prompt:** Great, can you create the same BDD gherkin test documents for the remaining user stories?

### Step 4 - Create Missing User Stories from the Badly Formatted Requirements Document
1. **Prompt:** Can you look at the document `functional-requirements.txt`, which is a functional requirement document for online shopping, and create any user stories from this that are missing from our current list?

### Step 5 - Create Remaining BDD Feature Documents for All the User Stories
1. **Prompt:** Finally, can you create the gherkin BDD feature documents for the user stories we haven't covered yet?