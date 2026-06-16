# My Report: Project Vault Sweep

I learned _a lot_ about how dangerous certain code can be and why things break when scripting. Here is a breakdown of what I found, why I had to flag certain things, and how I fixed the bugs in my own script.

---

## 1. Dangerous Code Patterns (What I Flagged and Why)

I set up the script to look through all our `.sh` (Shell) files for three major red flags. Here is what I learned about why these patterns are super risky:

### Destructive Commands (`rm -rf`, `mkfs`, `shutdown`, `reboot`)

- These are commands that can wipe data or turn off machines.
- If a script accidentally runs `rm -rf /` or a `mkfs` (make file system) command, it can completely erase the entire hard drive instantly. Also, unauthorized `shutdown` or `reboot` commands can crash our servers and take our app offline.

### Suspicious Piped Downloads (`curl` / `wget` piped into `sh` / `bash`)

- This is when a script downloads something from the internet and immediately runs it (using the `| bash` pipe).
- This runs unreviewed code directly on our server. We have no idea if the file changed since we last looked at it. It’s the easiest way for hackers to install malware or backdoors into our system.

### Insecure Permissions (World-Writable Files)

- This means a file has permissions like `chmod 777`, making it "world-writable."
- "World-writable" means _absolutely anyone_ (or any random guest process running on the computer) can edit the file. A hacker could easily sneak a bad line of code into that script, and the system would just run it without knowing.

---

## 2. Environment File Audit (Why My Script Rejected Certain Lines)

Next, I had the script check our `.env` files line-by-line. I had to make up some strict rules because environment files need to be super clean and secure. Here is why specific lines got thrown out:

- **`PASSWORD=secret123` and `TOKEN=abc` (Forbidden Keys)**
  - We cannot hardcode real secrets like passwords or API tokens into configuration files inside a monorepo. If a developer accidentally commits this to GitHub, our secrets are exposed to the world.
- **`KEY = value` (Spaces Around the Equal Sign)**
  - Basic environment parsers are kind of dumb—they break if there are spaces around the `=` sign. It always needs to be strictly written as `KEY=value` with no gaps.
- **`SERVER-NAME=x` (Invalid Characters in the Key)**
  - Environment variable keys can only use UPPERCASE letters, numbers, and underscores (`_`). Hyphens (`-`) are illegal characters and will break the script.
- **`USER="admin"` (Unnecessary Quotes)**
  - We don't need to wrap values in single or double quotes. The configuration parser just reads the raw characters anyway, so adding quotes is just bad syntax that can cause weird bugs later.
- **`export PATH=$PATH:/tmp` (System Variable Modification)**
  - `.env` files are only supposed to hold simple settings for our app. Trying to change core system paths like `PATH` is way too dangerous and shouldn't be allowed in a basic config file.

---

## 3. Technical Hurdles & How I Solved Them

Building the actual audit script was way harder than I thought! I ran into three major bugs that caused the script to crash or get stuck, but I figured out how to fix them:

### Infinite `.sanitized` File Loop

- I told the script to look for any file starting with `.env*`. When it ran, it cleaned `.env` and saved the clean version as `.env.sanitized`. But on the next loop, the script saw `.env.sanitized` (since it starts with `.env`), cleaned it _again_, and made `.env.sanitized.sanitized`. It kept doing this forever!
- I had to fix the `find` command. I added a rule that explicitly tells it to ignore any file ending in `.sanitized` by using `! -name "*.sanitized"`. Problem solved!

### Git Bash (Windows) vs. Linux File Permissions

- I originally wrote the script to look at the 9th character of a file's permission string to see if it had a `w` (meaning anyone can write to it). This worked on Linux, but when I tested it on Windows Git Bash, it failed. Windows uses NTFS permissions, which don't map perfectly to standard Linux permissions.
- I changed the script to look at _both_ the letter formatting (`%A`) and the numeric/octal code (`%a`) (like `777`). By checking both styles, the script now successfully catches dangerous permissions on both Windows and Linux.

### Freezing Inside a Loop

- I wanted the script to stop and ask the user: `"Fix it? (y/n)"` every time it found a bad line. But when it reached that part inside the loop, the script just froze or skipped right past it. This happened because the script was already using the text file as its "input stream" to read the lines, so it got confused and couldn't listen to my keyboard!
- I found out you can force the `read` command to look directly at the physical keyboard/screen instead of the file. I added `< /dev/tty` to the end of the user prompt command. Now, the script pauses perfectly and waits for me to type `y` or `n`.

### The major issue

when i pushed changes into the repo, i kept getting an error -
GitHub is blocking your push: your vault_sweep.log file contains real secrets (Stripe key, AWS key, GitHub token, etc.) that got committed.

The i realised that these keys were visible in .log file.

so i replaced the original key values with
STRIPE_SECRET_KEY=**_REDACTED_**
AWS_SECRET_ACCESS_KEY=**_REDACTED_**
GITHUB_TOKEN=**_REDACTED_**

but push is still being blocked because GitHub’s push protection sees a Stripe API key inside my commit history.

so i used these commands
pip install git-filter-repo
git filter-repo --path vault_sweep.log --invert-paths

## Thank you team for this exposure. This is my first time learning abt DEVOPS and glad i got to know something abt this domain.
