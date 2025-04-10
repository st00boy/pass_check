# 🔐 Password Strength Checker (Bash)

A user-friendly password analysis tool written in Bash with a Dialog-based GUI. It estimates password strength, entropy, and potential crack time, checks against [HaveIBeenPwned](https://haveibeenpwned.com/), and provides a secure, interactive experience.

---

## ✨ Features

- Interactive **Dialog-based UI**
- Entropy calculation and estimated crack time
- **Customizable rules** (symbols, digits, uppercase/lowercase, length)
- Clipboard support via `xclip`
- Batch mode for analyzing multiple passwords from a file
- Online **leak check** using the HaveIBeenPwned API (k-Anonymity method)
- Settings menu to configure rules
- Password generator
- Desktop launcher support

---

## 🛠️ Installation

### Automatic Installer (Recommended)

```bash
chmod +x installer.sh
./installer.sh

💻 Manual Usage
Run the script manually:

chmod +x password_checker.sh
./password_checker.sh

 Dependencies
Ensure the following are installed:

dialog

curl

awk

sha1sum

iconv

xclip (for clipboard support)

Install them with:

# Debian/Ubuntu
sudo apt install dialog curl xclip

# Arch
sudo pacman -S dialog curl xclip

# Fedora
sudo dnf install dialog curl xclip


🧪 Example Use
🔍 Check a single password interactively

📁 Analyze a password list file (batch mode)

🔧 Customize rule settings in the Settings menu

🔐 Generate strong passwords with desired complexity


📦 Files
password_checker.sh – Main script

installer.sh – Installs dependencies, script, and optional launcher

README.md – You're reading it!


🧠 How It Works
Entropy is calculated based on character set and length using the formula:
                                                                             Entropy = log2(charset_size ^ password_length)

The script estimates the crack time and queries HaveIBeenPwned using the k-Anonymity model (only the first 5 characters of the SHA1 hash are sent).


🛡️ Security Notice
This tool does not store or transmit your full password. When checking against leaks, it uses a hashed partial prefix to preserve your privacy.


🧑‍💻 Author
Made with ❤️ in Bash by st00boy

Feel free to contribute, suggest features, or report issues!

