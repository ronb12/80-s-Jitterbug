# Fix "pack-objects died of signal 10" when pushing to GitHub

Signal 10 (SIGBUS) during `git push` often happens when Git uses too much memory while creating the pack. Run these in your project **root** (the folder that contains `.git`), e.g. `80's Jitterbug`:

## 1. Limit memory used while packing (run in repo root)

```bash
cd "/Users/ronellbradley/Desktop/80's Jitterbug"

git config pack.windowMemory "10m"
git config pack.packSizeLimit "20m"
git config pack.deltaCacheSize "10m"
```

## 2. Increase HTTP buffer (if using HTTPS)

```bash
git config http.postBuffer 524288000
```

## 3. Try pushing again

```bash
git push -u origin main
```

---

## If it still fails: push without thin pack

```bash
git push -u origin main --no-thin
```

---

## Nuclear option: fresh clone and re-apply your changes

If the repo is corrupted or the push keeps failing:

1. **Back up your current folder** (e.g. rename `80's Jitterbug` to `80's Jitterbug-backup`).

2. **Clone fresh from GitHub:**
   ```bash
   cd ~/Desktop
   git clone https://github.com/ronb12/80-s-Jitterbug.git "80's Jitterbug-new"
   cd "80's Jitterbug-new"
   ```

3. **Copy your latest code over** (replace the contents of the clone with your backup’s contents, but keep the new clone’s `.git` folder).

4. **Commit and push from the new clone:**
   ```bash
   git add -A
   git status
   git commit -m "Sync latest 80s Jitterbug site"
   git push -u origin main
   ```

5. Once the push succeeds, you can remove the backup and rename `80's Jitterbug-new` to `80's Jitterbug` if you like.
