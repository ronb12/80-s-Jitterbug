# Fix timeout and deploy

The timeout happens because the folder name **80's Jitterbug** contains an apostrophe. Many tools (npm, Node, Cursor) can hang or time out when reading from that path.

## One-time fix: rename the folder and deploy

1. **Copy the rename script to your Desktop**  
   In Finder: open the **80's Jitterbug** folder, find **rename-and-deploy.sh** (in the parent of `jitterbug-site`), and drag it to your **Desktop**.

2. **Run it from Terminal** (don’t `cd` into 80's Jitterbug):
   ```bash
   cd ~/Desktop && bash rename-and-deploy.sh
   ```
   The script will:
   - Rename **80's Jitterbug** → **80s-Jitterbug** (no apostrophe)
   - Build and deploy from **80s-Jitterbug/jitterbug-site**

3. **Use the new folder from now on**  
   Open **80s-Jitterbug** in Cursor and run future builds/deploys from there. You can delete the script from Desktop after a successful deploy.

---

## If you prefer to rename by hand

1. In Finder, on your Desktop, **rename** the folder **80's Jitterbug** to **80s-Jitterbug** (no apostrophe).
2. In Terminal:
   ```bash
   cd ~/Desktop/80s-Jitterbug/jitterbug-site
   npm run build
   firebase deploy --only hosting
   ```

After the folder has no apostrophe, timeouts from this path should stop.
