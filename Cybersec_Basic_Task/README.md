# WELCOME TO CRYPTOVAULT

This project explores three progressively stronger vault designs:

1. Stage 1 uses a Caesar cipher for basic CLI file encryption.
2. Stage 2 adds hash-based integrity checking with `--verify`.
3. Stage 3 upgrades the vault to AES-256-CBC with password-based key derivation.

## How to Run

My submission is in the zip file Hiba_cryptovault.zip. This zip file contains the script `cryptovault.py` and my writeup .The script automatically branches into the **Caesar Engine** (Stages 1 & 2) or the **AES Engine** (Stage 3) based on your command flags (`--shift` vs `--password`).

1. Unzip the submission archive into a clean directory.
2. Open your terminal or command prompt in that directory.
3. Install the required cryptographic dependency:

   ```bash
   pip install cryptography
   ```

# Demo video

[<video src="demo video.mp4" controls width="600"></video>](https://drive.google.com/file/d/1e4vw-Cc5-TN7qQIgEYw3PgazJBcdnAsq/view?usp=sharing)

# STAGE 1: CAESAR LOCK

Encrypt and decrypt text files from the command line with a Caesar shift.

Usage:

python cryptovault.py encrypt message.txt --shift 7
python cryptovault.py decrypt message.txt.enc --shift 7
python cryptovault.py crack message.txt.enc

Behavior:

- `encrypt` writes `<file>.enc`.
- `decrypt` writes `<file>.dec`.
- `crack` prints the top 5 likely plaintext guesses using frequency analysis.

# STAGE 2: HASH GUARD

Stage 2 adds integrity protection on top of encryption.

Requirements:

- Before encrypting, compute a SHA-256 hash of the file.
- Store the hash inside the encrypted output.
- On decryption, recompute the hash and compare it to the stored value.
- Print a success message when the file is intact.
- Print a tamper warning when the hash does not match.

# STAGE 3: AES UPGRADE

Stage 3 replaces Caesar with AES-256-CBC and supports any file type.

Usage:

python cryptovault_stage3.py encrypt topsecret.txt --password mypass
python cryptovault_stage3.py decrypt topsecret.txt.enc --password mypass

Behavior:

- Stage 3 reads and writes files as raw binary bytes.
- `encrypt` writes `<file>.enc`.
- `decrypt` restores the original file name when possible.

Requirements:

- Encrypt and decrypt any file type, not just text.
- Derive the AES key from a password using PBKDF2 with a random salt.
- Never use the raw password as the key.
- Generate a fresh random IV for each encryption.
- Store the salt and IV in the `.enc` file header so decryption can recover them.
- Keep the Stage 2 integrity check working end-to-end.

# COMMAND RULES AND SYNTAX

1. ENCRYPT: Scrambles a file using the selected keying method.
   Stage 1 syntax: python cryptovault.py encrypt <file> --shift <n>

Stage 2 syntax: python cryptovault.py encrypt <file> --shift <n> (The script automatically generates and embeds the SHA-256 hash inside the output file)

Stage 3 syntax: python cryptovault.py encrypt <file> --password <pass>

2. DECRYPT: Restores a file using the matching keying method.
   Stage 1 syntax: python cryptovault.py decrypt <file> --shift <n>

Stage 2 syntax: python cryptovault.py decrypt <file> --shift <n> --verify (The optional --verify flag activates the SHA-256 seal integrity check)

Stage 3 syntax: python cryptovault.py decrypt <file> --password <pass> (The integrity check runs automatically end-to-end)

3. CRACK: Uses frequency analysis to guess Caesar plaintexts without a key.

Notes:

- `--verify` is optional in Stage 1 and checks the embedded SHA-256 seal.
- `crack` prints the top 5 likely plaintext guesses instead of writing a file.
- Stage 3 uses AES-256-CBC with PBKDF2-derived keys, salt, and IV headers.

# Output

### Command - python cryptovault.py crack test.txt

--- Frequency Analysis: Top 5 Likely predictions ---

Guess 1 (Assuming 'r' is 'e' -> Shift 13):
Jxu gkysa rhemd ven zkcfi eluh jxu bqpo tew. Shofjewhqfxo yi jxu qhj ev
mhyjydw

Guess 2 (Assuming 'w' is 'e' -> Shift 18):
Esp bftnv mczhy qzi ufxad zgpc esp wlkj ozr. Ncjaezrclasj td esp lce zq
hctetyr

Guess 3 (Assuming 'u' is 'e' -> Shift 16):
Gur dhvpx oebja sbk whzcf bire gur ynml qbt. Pelcgbtencul vf gur neg bs
jevgvat

Guess 4 (Assuming 'h' is 'e' -> Shift 3):
The quick brown fox jumps over the lazy dog. Cryptography is the art of
writing

Guess 5 (Assuming 'l' is 'e' -> Shift 7):
Pda mqeyg xnksj bkt fqilo kran pda hwvu zkc. Ynulpkcnwldu eo pda wnp kb
snepejc

# Built For Spider Inductions 26 - CyberSecurity Basic Task
