# Writing in My Voice

Anything an AI drafts that goes out under my name should sound like I wrote it: PR comments
and reviews, Slack messages, email, issue comments, LinkedIn posts, and blog drafts. This file
describes that voice. `documentation.md` still applies on top of it for technical docs.

The reference is my blog at benniemosher.com, especially the 2026 posts in the "Learning"
category, such as "SLIs, SLOs and Error Budgets".

## How I sound

- **First person, conversational.** I write "I", "we", and "you", with contractions: "I've",
  "it's", "that's", "I'd". It reads like a note to a coworker, not a report.
- **Full sentences.** Keep subjects and objects. "I'm blocked by X", not "blocked on X". "I
  destroyed the old environment", not "Destroyed old env". Concision means cutting filler and
  repetition, not grammar.
- **Context first.** Open with one sentence on what this is and why the reader is getting it,
  then the detail. "I've been working through Google's SRE book, and the first thing it makes
  you do is get three terms straight."
- **Plain and direct.** Short sentences, with a very short one now and then to land a point:
  "That's it." No hype, no "excited to share", no hashtags, no fragment hooks, no takeaway
  lists at the end.
- **Honest about mistakes and gaps.** I say when I got something wrong and what I changed: "My
  first SLI was wrong." "I got 'valid' backwards the first time." I say what isn't done or
  checked yet.
- **Concrete.** Real numbers, real services, real commands, and links to the exact commit or
  file. "About 12 events a month, so one failure is an 8% error rate", not "low traffic".
- **Say how I know.** "I did test it. I fed the alerts a fake 95% success rate, and both fired."
  In a PR, "checked at `abc1234`" or "ran X".
- **Answer the obvious question.** If the reader will ask something, ask it and answer it: "My
  first question was the obvious one."
- **Close with what's next** when there is a next step, in one line.

## Mechanics

- Use the Oxford comma: "SLIs, SLOs, and error budgets".
- Prefer commas and periods to em dashes.
- Grammarly preferences I've accepted: "along the way" over "as I go", "for each" over "on
  each".
- Bold sparingly, for the one term a paragraph defines. Use tables for numbers that compare.

## By channel

- **PR comments and reviews:** thank a reviewer by name when they did real work ("Thanks,
  @name."). Answer their questions as a numbered list in their order, one short paragraph
  each. Name the commit that addresses them. Follow `code-review.md` for review severity
  labels.
- **Slack:** lead with the orienting sentence, then the detail. Keep the summary short and put
  the long version in the PR or issue, with a link.
- **LinkedIn:** "I'm writing up what I learn along the way, and the first one is up", one
  concrete detail that gives a reason to click, the link, and a line on what's next.
- **Blog:** the same voice, with diagrams and tables where they help, and the sources linked
  at the end.

## Before sending

- Show me the draft first. I post it unless I've said otherwise.
- Reread it as if I'm saying it out loud to the person. If a sentence sounds like a template
  or a press release, rewrite it.
