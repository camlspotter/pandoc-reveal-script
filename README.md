---
theme: simple 
header-includes: |
  <link rel="stylesheet" type="text/css" href="mystyle.css">
  <script>
      Reveal.initialize({
		autoAnimateDuration: 0.1
      });
  </script>
transition: none
---
## pandoc-reveal-script

Write your slide in MarkDown.

Compile it to HTML using Pandoc + Reveal.js.

A script to auto compile + preview.

<https://github.com/camlspotter/pandoc-reveal-script>

## How to use

Requirements

* Reveal.js at ../reveal.js-4.1.0
* `fswatch`
* `pandoc`
* Chrome and `chrome-cli`

## Write a Markdown

```markdown
---
theme: simple 
header-includes: |
  <link rel="stylesheet" type="text/css" href="XXX.css">
  <script>
      Reveal.initialize({
      		autoAnimateDuration: 0.1, 
		// other Reveal.js options
      });
  </script>
transition: none
---
## Title

Hello world
```

## Change visual using CSS

Example: `./mystyle.css`

## Start `./command.sh`

`$ ./command.sh`

It monitors `*.md` and `*.css` file changes:

* Compile MarkDowns to HTMLs: `_build/XXX.html`
* Display HTMLs on Chrome

## Print slides to PDF

`$ ./command.sh print`

## Make 1 file HTML with inlined images

`$ ./command.sh compile`

creates `_build/XXX-self-contained.html`
