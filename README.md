# Advanced Computer Architecture — Public Course Site

Static GitHub Pages site for **Advanced Computer Architecture, Monsoon 2026**
(IIIT Hyderabad), co-taught by Priyesh Shukla and Suresh Purini. Plain
hand-written `index.html` + `style.css`, styled to match
[sureshpurini.github.io](https://sureshpurini.github.io/) and the sibling
[FPGA course site](https://github.com/sureshpurini/fpga-monsoon26-web).

**This repo is deliberately public and separate from the private course repos
(`aca-monsoon26`, `aca-monsoon26-instructor`).** Keep it that way:

> ⚠️ **Never** put copyrighted readings (H&P, papers behind paywalls), instructor
> notes, exams, solutions, grading sheets, or student data in this repo. Those
> live in `aca-monsoon26-instructor/instructor/` and on **Moodle**. This site
> holds only the public brochure: overview, schedule, released slides, links,
> logistics.

## Layout

```
index.html          the whole site — overview, schedule, coursework, resources, logistics
style.css           design tokens + components (shared identity with the FPGA site)
slides/             published lecture decks, one self-contained HTML each
publish-slides.sh   copies built decks out of ../aca-monsoon26 under site lecture numbers
```

## Lecture numbering

The site numbers lectures **continuously across both instructors**, which does
*not* match the folder names in `aca-monsoon26`:

| Site | Course repo folder | Instructor |
|------|--------------------|------------|
| L1, L2 | *(Priyesh's decks — not yet released)* | Priyesh Shukla |
| L3 | `lectures/L1-digital-circuits-bsv` | Suresh Purini |
| L4 | `lectures/L2-tiny-processor` | Suresh Purini |
| L5 | `lectures/L3-drum-processor` | Suresh Purini |
| L6+ | see `aca-monsoon26-instructor/LECTURE_PLAN.md` | — |

`publish-slides.sh` encodes that mapping. The lecture plan in the instructor repo
still numbers the ILP module from 3; the three Bluespec lectures shift it down by
three, and the site reflects the shifted numbering.

## Publishing slides

```bash
./publish-slides.sh            # copy already-built decks into slides/
./publish-slides.sh --build    # rebuild each deck from slides.md first, then copy
```

Each deck is built by its own `build-html.sh` in the course repo: it strips the
`PRESENTER NOTES` comment blocks and inlines every figure as a base64 data URI,
so the published file is a single self-contained HTML with nothing private in it.
Verify before pushing:

```bash
grep -c "PRESENTER NOTES" slides/*.html   # must all be 0
```

**Priyesh's L1 and L2 decks are not published yet.** Once he approves, drop them
in as `slides/L1.html` / `slides/L2.html` and replace the two
`<span class="pending">Slides — pending release</span>` markers in `index.html`
with `<a class="slide-link" href="slides/L1.html" …>Slides →</a>`.

## Edit

- Content: `index.html` · Styling: `style.css`
- Search for `TODO` / `todo` to find the placeholders to fill in (meeting
  time/venue, office hours, TAs, credits, grading weights).
- Preview locally: `python3 -m http.server 8000` then open `http://localhost:8000/`.

## Deploy (first time)

```bash
git add -A && git commit -m "Initial course site"
gh repo create aca-monsoon26-web --public --source=. --remote=origin --push
gh api -X POST repos/:owner/aca-monsoon26-web/pages -f source[branch]=master -f source[path]=/ 2>/dev/null \
  || echo "Enable Pages in Settings → Pages → Branch: master / root"
```

Live at `https://sureshpurini.github.io/aca-monsoon26-web/`. Add that URL to the
Teaching section of your homepage.

## Update later

```bash
git add -A && git commit -m "Update schedule" && git push
```

Pages redeploys automatically on push (usually within a minute).
