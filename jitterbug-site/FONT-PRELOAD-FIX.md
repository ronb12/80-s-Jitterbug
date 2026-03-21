# Fix: Font preloaded but not used (woff2 warning)

The browser warning:

```
The resource ... 5c285b27cdda1fe8-s.p.a62025f2.woff2 was preloaded using link preload but not used within a few seconds
```

comes from **next/font** preloading a DM Sans font file that isn’t used immediately on first paint (e.g. a specific weight used only below the fold). Disabling font preload removes the warning; the font still loads when needed.

## Change to make

In **`src/app/layout.tsx`**, update the `DM_Sans` config to include `preload: false`:

**Before:**

```ts
const dmSans = DM_Sans({
  variable: "--font-dm-sans",
  subsets: ["latin"],
  display: "swap",
  weight: ["400", "500", "600", "700"],
});
```

**After:**

```ts
const dmSans = DM_Sans({
  variable: "--font-dm-sans",
  subsets: ["latin"],
  display: "swap",
  weight: ["400", "500", "600", "700"],
  preload: false,
});
```

Then rebuild and redeploy. The font will still load and display; only the preload link is disabled, so the console warning should go away.
