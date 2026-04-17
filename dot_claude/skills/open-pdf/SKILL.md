---
name: open-pdf
description: Open a PDF file in Preview next to the current terminal window
allowed-tools: Bash, Read, Glob
argument-hint: <file-path-or-url>
---

# Open PDF

Open a PDF in Preview for side-by-side viewing with the terminal. Handle both local files and URLs (e.g., arXiv links).

## Arguments
- `path_or_url` (required): A local file path to a PDF, or a URL to download one from (e.g., an arXiv abstract or PDF URL).

## Steps

1. **Determine if the argument is a URL or local path.**
   - If it's a URL:
     - If it's an arXiv abstract URL (e.g., `https://arxiv.org/abs/XXXX.XXXXX`), convert it to the PDF URL (`https://arxiv.org/pdf/XXXX.XXXXX`).
     - Download the PDF to `/tmp/` with a descriptive filename using `curl -sL -o`.
     - Verify the downloaded file is a valid PDF with `file`.
   - If it's a local path:
     - Verify the file exists and is a PDF.

2. **Open the PDF in Preview.**
   ```bash
   open -a Preview <path-to-pdf>
   ```

3. Do NOT modify, convert, annotate, or do anything else to the PDF.
4. Do NOT open the PDF in any app other than Preview.
5. Do NOT summarize or read the PDF contents — just open it.

## Verification
- Confirm the `open` command exited successfully (exit code 0).
- Print: "Opened <filename> in Preview."
