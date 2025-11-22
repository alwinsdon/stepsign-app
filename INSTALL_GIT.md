# 🚀 Install Git - Quick Guide

## Method 1: Download Git for Windows (Easiest)

### Step 1: Download
1. Go to: **https://git-scm.com/download/win**
2. Download will start automatically (64-bit version)
3. Or click: **"Click here to download manually"**

### Step 2: Install
1. Run the downloaded `.exe` file
2. Click **"Next"** through the installer
3. **Important settings** (use defaults for others):
   - ✅ Select: "Git from the command line and also from 3rd-party software"
   - ✅ Select: "Use Visual Studio Code as Git's default editor" (if you use VS Code)
   - ✅ Select: "Override the default branch name for new repositories" → "main"
   - ✅ Select: "Git Credential Manager"
4. Click **"Install"**
5. Click **"Finish"**

### Step 3: Verify Installation
Open a new PowerShell/Command Prompt and run:
```bash
git --version
```

You should see: `git version 2.x.x`

---

## Method 2: Install via Winget (Windows Package Manager)

If you have Windows 11 or Windows 10 (recent version):

```bash
# Open PowerShell as Administrator
winget install --id Git.Git -e --source winget
```

---

## Method 3: Install via Chocolatey

If you have Chocolatey installed:

```bash
# Open PowerShell as Administrator
choco install git
```

---

## After Installation

### 1. Configure Git (Required)
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 2. Verify Configuration
```bash
git config --list
```

### 3. Restart Your Terminal/VS Code
Close and reopen any terminal windows or VS Code to recognize Git.

---

## Then Push to GitHub

Once Git is installed, run these commands:

```bash
# Navigate to your project
cd "C:\Users\alwin\Downloads\StepSign Mobile App Design (1)"

# Initialize git
git init

# Add all files
git add .

# Commit
git commit -m "Complete Flutter implementation - All 9 screens"

# Create repo on GitHub first at: https://github.com/new
# Then connect and push:
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git
git branch -M main
git push -u origin main
```

---

## Quick Links

- **Download Git**: https://git-scm.com/download/win
- **Git Documentation**: https://git-scm.com/doc
- **GitHub Account**: https://github.com/signup

---

## Troubleshooting

### Git not recognized after install?
- **Solution**: Restart your terminal/VS Code
- Or add Git to PATH manually:
  - Default location: `C:\Program Files\Git\cmd`

### Need GitHub Desktop instead?
- Download: https://desktop.github.com/
- Easier GUI interface, no command line needed

---

## Next Steps After Installing

1. ✅ Install Git (using method above)
2. ✅ Configure your name and email
3. ✅ Create GitHub repository
4. ✅ Push your Flutter app
5. ✅ GitHub Actions will auto-build APK

**Let me know once Git is installed and I'll help you push!** 🚀

